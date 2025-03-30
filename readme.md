# Multiple CI Runner in Docker

This Container includes multiple CI Runners and additional Tools.

## System Requirements
- [amd64](https://hub.docker.com/repository/docker/ravermeister/ci-runner/tags?name=amd64) (images are based on [Debian:stable-slim](https://hub.docker.com/_/debian/tags?name=stable-slim))
- [arm64](https://hub.docker.com/repository/docker/ravermeister/ci-runner/tags?name=arm64) (images are based on [arm64v8/debian:stable-slim](https://hub.docker.com/r/arm64v8/debian/tags?name=stable-slim))
- Docker

## Software included:
See also the [versions.env](https://gitlab.rimkus.it/development/ci-runner/-/blob/main/.env/versions.env?ref_type=heads) for the Software.

### Runner
- [Forgejo Runner](https://code.forgejo.org/forgejo/runner/releases) in `/usr/local/bin/forgejo-runner`
- [Woodpecker Runner](https://github.com/woodpecker-ci/woodpecker/releases) in `/usr/local/bin/woodpecker-agent`
- [Gitlab Runner](https://gitlab.com/gitlab-org/gitlab-runner/-/releases) in `/usr/local/bin/gitlab-runner`

### Tools
- node
- go
- docker-ce-cli
- docker-buildx
- git
- git-lfs

## How to run

Before starting, you have to configure a runner:

### configure forgejo-runner
before using this image you have to generate a `config.yml`
```shell
wget -qO docker-compose.yml https://gitlab.rimkus.it/development/ci-runner/-/raw/main/docker-compose.yml?ref_type=heads
docker-compose pull
docker-compose run -it --entrypoint ci-runner forgejo generate-config>config.yml
touch runner.cfg
docker-compose run -v $(pwd)/runner.cfg:/root/.runner -it --entrypoint ci-runner forgejo register
```

you can use the [docker-compose](https://gitlab.rimkus.it/development/ci-runner/-/blob/main/docker-compose.yml?ref_type=heads) as an example
of how to run this image. 

### configure woodpecker-agent
If you only want to start a single agent, 
use the `WOODPECKER_*` Environment Variables to configure the agent.
See the [Docker Compose](https://gitlab.rimkus.it/development/ci-runner/-/blob/main/docker-compose.yml?ref_type=heads) 

If you want several agents running within one Container:  
create a config directory for woodpecker and add a file named `*.agent` for each agent.
Add the `WOODPECKER_*` Variables into the file
```
WOODPECKER_SERVER=woodpecker-grpc.codeberg.org
WOODPECKER_AGENT_SECRET=XXXXXXXXXXXXXXXXX
WOODPECKER_GRPC_SECURE=true
WOODPECKER_HEALTHCHECK=false
WOODPECKER_BACKEND=docker
WOODPECKER_HOSTNAME=woodpecker
WOODPECKER_AGENT_LABELS=owner=raver
WOODPECKER_MAX_WORKFLOWS=2
```
mount the config Directory into `/etc/woodpecker` e.g.:  
```yaml
  woodpecker:
    image: docker.io/ravermeister/ci-runner
    hostname: woodpecker
    restart: unless-stopped
    networks:
      - ci-bridge-net
    depends_on:
      docker:
        condition: service_healthy
    environment:
      CI_RUNNER: woodpecker
    volumes:
      - /etc/ci-runner/woodpecker:/etc/woodpecker
```
### configure gitlab-runner
See the general [Documentation](https://docs.gitlab.com/runner/register/) how to Register a runner.
Prefix the given command with the container from docker-compose:
```shell
wget -qO docker-compose.yml https://gitlab.rimkus.it/development/ci-runner/-/raw/main/docker-compose.yml?ref_type=heads
docker-compose pull
mkdir gitlab && touch gitlab/config.toml
docker-compose run -it -v $(pwd)/gitlab:/etc/gitlab-runner --entrypoint gitlab-runner gitlab register
```

## Remove Access to LAN for the Container
To further harden the Isolation,
the Docker compose uses a separate bridge Network with a pre-defined name `ci-bridge-net`, 
you can verify this with the `ip a` command. You should see a new Network device called `ci-bridge-net`. 
Now you can add an [IPTable rule](https://stackoverflow.com/a/45121429), to prohibit Access to the LAN.

```bash
iptables -I FORWARD -i ci-bridge-net -d 192.168.0.0/16 -j DROP
ip6tables -I FORWARD -i ci-bridge-net -d 2a02:8464:7240:a2b0::/64 -j DROP
# persist the ip table rules
iptables-save >/etc/iptables/rules.v4
ip6tables-save >/etc/iptables/rules.v6
```