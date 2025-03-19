# update base image
FROM debian:stable-slim AS update_base
SHELL ["/bin/sh", "-c"]
ENV LANG=C.UTF-8
# Install required packages
RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -q \
    # Upgrade Base Image
    && apt-get dist-upgrade -yq --no-install-recommends \
    # Install Dependencies
    && apt-get install -yq --no-install-recommends \
        ca-certificates curl nodejs npm nano \
    # Add the Docker CE repository to Apt sources
    &&  echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
          $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
          tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update -q \
    # install Docker CE Client
    && apt-get install docker-ce-cli \
    # clean APT
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \    
    # Remove MOTD
    && rm -rf /etc/update-motd.d /etc/motd /etc/motd.dynamic \
    && ln -fs /dev/null /run/motd.dynamic

# amd64 base
FROM debian:stable-slim AS base_amd64
ARG FORGEJO_VERSION=6.2.2
ARG WOODPECKER_VERSION=3.4.0
ARG GITLAB_VERSION=17.9.1
ARG GO_VERSION=1.24.1
COPY --from update_base / /
ADD --chmod=755 https://code.forgejo.org/forgejo/runner/releases/download/v${FORGEJO_VERSION}/forgejo-runner-${FORGEJO_VERSION}-linux-amd64 /usr/local/bin/forgejo-runner
ADD --chmod=755 https://gitlab-runner-downloads.s3.amazonaws.com/v${GITLAB_VERSION}/binaries/gitlab-runner-linux-amd64 /usr/local/bin/gitlab-runner
ADD https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz /tmp/tools/go.tar.gz
ADD https://github.com/woodpecker-ci/woodpecker/releases/download/v${WOODPECKER_VERSION}/woodpecker-agent_linux_amd64.tar.gz /tmp/tools/woodpecker-agent.tar.gz
COPY --chmod=755 assets/ci-runner /usr/local/bin/
RUN ci-runner setup

# arm64 base
FROM arm64v8/debian:stable-slim AS base_arm64
ARG FORGEJO_VERSION=6.2.2
ARG WOODPECKER_VERSION=3.4.0
ARG GITLAB_VERSION=17.9.1
ARG GO_VERSION=1.24.1
COPY --from update_base / /
ADD --chmod=755 https://code.forgejo.org/forgejo/runner/releases/download/v${FORGEJO_VERSION}/forgejo-runner-${FORGEJO_VERSION}-linux-arm64 /usr/local/bin/forgejo-runner
ADD --chmod=755 https://gitlab-runner-downloads.s3.amazonaws.com/v17.9.0/binaries/gitlab-runner-linux-arm /usr/local/bin/gitlab-runner
ADD https://github.com/woodpecker-ci/woodpecker/releases/download/v${WOODPECKER_VERSION}/woodpecker-agent_linux_arm64.tar.gz /tmp/tools/woodpecker-agent.tar.gz
ADD https://go.dev/dl/go${GO_VERSION}.linux-arm64.tar.gz /tmp/tools/go.tar.gz
COPY --chmod=755 assets/ci-runner /usr/local/bin/


# arm64 forgejo-runner
FROM base_arm64 AS ci-runner-arm64
ENV CI_RUNNER="forgejo"
WORKDIR /root
ENTRYPOINT ["ci-runner", "run"]

# amd64 forgejo-runner
FROM base_amd64 AS ci-runner-amd64
ENV CI_RUNNER="forgejo"
WORKDIR /root
ENTRYPOINT ["ci-runner", "run"]