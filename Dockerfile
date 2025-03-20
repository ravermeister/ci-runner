ARG DOCKER_BASE_IMAGE=debian:stable-slim

# create image
FROM $DOCKER_BASE_IMAGE
ARG FORGEJO_VERSION=6.2.2
ARG WOODPECKER_VERSION=3.4.0
ARG GITLAB_VERSION=17.9.1
ARG GO_VERSION=1.24.1
# linux-arm64 or linux-amd64
ARG FORGEJO_ARCH=linux-amd64
# linux-arm or linux-amd64
ARG GITLAB_ARCH=linux-arm
# linux_arm64 or linux_amd64
ARG WOODPECKER_ARCH=linux_arm64
# linux-arm64 or linux-amd64
ARG GO_ARCH=linux-arm64

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
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    &&  echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
          $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
          tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update -q \
    # install Docker CE Client
    && apt-get install -yq --no-install-recommends \
        docker-ce-cli docker-buildx-plugin docker-compose-plugin \
    # clean APT
    && apt-get -yq clean \
    && rm -rf /var/lib/apt/lists/* \
    # Remove MOTD
    && rm -rf /etc/update-motd.d /etc/motd /etc/motd.dynamic \
    && ln -fs /dev/null /run/motd.dynamic \
    # install tools
    && tar -C /usr/local/share -xzf /tmp/tools/go.tar.gz \
    && find /usr/local/share/go/bin -type f -exec ln -s {} /usr/local/bin \; \
    && tar -C /usr/local/bin -xzf /tmp/tools/woodpecker-agent.tar.gz \
    && rm -rf /tmp/tools

ADD --chmod=755 https://code.forgejo.org/forgejo/runner/releases/download/v${FORGEJO_VERSION}/forgejo-runner-${FORGEJO_VERSION}-${FORGEJO_ARCH} /usr/local/bin/forgejo-runner
ADD --chmod=755 https://gitlab-runner-downloads.s3.amazonaws.com/v${GITLAB_VERSION}/binaries/gitlab-runner-${GITLAB_ARCH} /usr/local/bin/gitlab-runner
ADD https://github.com/woodpecker-ci/woodpecker/releases/download/v${WOODPECKER_VERSION}/woodpecker-agent_${WOODPECKER_ARCH}.tar.gz /tmp/tools/woodpecker-agent.tar.gz
ADD https://go.dev/dl/go${GO_VERSION}.${GO_ARCH}.tar.gz /tmp/tools/go.tar.gz
COPY --chmod=755 assets/ci-runner /usr/local/bin/

ENV CI_RUNNER="forgejo"
WORKDIR /root
ENTRYPOINT ["ci-runner", "run"]