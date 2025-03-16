# Forgejo Runner in Docker
The [amd64](https://hub.docker.com/repository/docker/ravermeister/forgejo-runner/tags?name=amd64) is based on ` Debian:slim`. 
The [arm64](https://hub.docker.com/repository/docker/ravermeister/forgejo-runner/tags?name=arm64) is based on `arm64v8/debian:stable-slim`.

## System Requirements
- Docker

## Software included:
- Forgejo Runner in `/usr/local/bin/forgejo-runner`
- node
- go
- docker-ce-cli

## How to run
This image can be used as a forgejo host and docker runner.
Additionally,
it can be enriched with [additional tools](https://gitlab.rimkus.it/development/forgejo-runner/-/blob/main/assets/forgectrl?ref_type=heads) Very easily.

before using this image you have to generate a `config.yml`
```bash
wget -qO docker-compose.yml https://gitlab.rimkus.it/development/forgejo-runner/-/raw/main/docker-compose.yml?ref_type=heads
docker-compose pull
docker-compose run -it --entrypoint forgejo-runner forgejo generate-config>config.yml
touch runner.cfg
docker-compose run -v runner.cfg:/root/.runner -it --entrypoint forgejo-runner forgejo register>config.yml
```

you can use the [docker-compose](https://gitlab.rimkus.it/development/forgejo-runner/-/blob/main/docker-compose.yml?ref_type=heads) as an example
of how to run this image. 
