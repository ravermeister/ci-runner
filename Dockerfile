ARG DOCKER_BASE_IMAGE=debian:stable-slim

# create image
FROM $DOCKER_BASE_IMAGE
ARG FORGEJO_VERSION=6.2.2
ARG WOODPECKER_VERSION=3.4.0
ARG GITLAB_VERSION=17.9.1
ARG GO_VERSION=1.24.1
ARG DOCKER_BUILDX_VERSION=0.22.0

# linux-arm64 or linux-amd64
ARG FORGEJO_ARCH=linux-amd64
# linux-arm or linux-amd64
ARG GITLAB_ARCH=linux-arm
# linux_arm64 or linux_amd64
ARG WOODPECKER_ARCH=linux_arm64
# linux-arm64 or linux-amd64
ARG GO_ARCH=linux-arm64
# linux-arm64 or linux-amd64
ARG DOCKER_BUILDX_ARCH=linux-amd64

# add packages
ADD --chmod=755 https://code.forgejo.org/forgejo/runner/releases/download/${FORGEJO_VERSION}/forgejo-runner-${FORGEJO_VERSION}-${FORGEJO_ARCH} /usr/local/bin/forgejo-runner
ADD --chmod=755 https://github.com/docker/buildx/releases/download/${DOCKER_BUILDX_VERSION}/buildx-${DOCKER_BUILDX_VERSION}.${DOCKER_BUILDX_ARCH} /root/.docker/cli-plugins/docker-buildx
ADD https://github.com/woodpecker-ci/woodpecker/releases/download/${WOODPECKER_VERSION}/woodpecker-agent_${WOODPECKER_ARCH}.tar.gz /tmp/tools/woodpecker-agent.tar.gz
ADD https://go.dev/dl/${GO_VERSION}.${GO_ARCH}.tar.gz /tmp/tools/go.tar.gz
COPY --chmod=755 assets/ci-runner /usr/local/bin/

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
        ca-certificates curl nodejs npm nano git  \
    # Add the Docker CE repository to Apt sources
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    &&  echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
          $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
          tee /etc/apt/sources.list.d/docker.list > /dev/null \
    # Add the git-lfs repos
    && curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash \
    && apt-get update -q \
    # Add the gitlab-runner repos
    && curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | bash \
    # Install
    ## Docker CE Client
    ## git-lfs \
    ## gitlab-runner
    && apt-get install -yq --no-install-recommends \
        docker-ce-cli \
        docker-buildx-plugin  \
        docker-compose-plugin  \
        git-lfs \
        gitlab-runner=$GITLAB_VERSION  \
        gitlab-runner-helper-images=$GITLAB_VERSION \
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

ENV CI_RUNNER="forgejo"
WORKDIR /root
ENTRYPOINT ["ci-runner", "run"]