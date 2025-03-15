# amd64 base
From debian:stable-slim as base_amd64
ARG FORGEJO_VERSION=6.2.2
ARG FORGEJO_BASE_URL=https://code.forgejo.org/forgejo/runner/releases/download
ADD --chmod=755 ${FORGEJO_BASE_URL}/v${FORGEJO_VERSION}/forgejo-runner-${FORGEJO_VERSION}-linux-amd64 /usr/local/share/forgejo/forgejo-runner

# amd64 forgejo-runner
FROM base_amd64 as forgejo-runner-amd64
ENTRYPOINT ["/usr/local/share/forgejo/forgejo-runner"]

##################################

# arm64 base
From arm64v8/debian:stable-slim as base_arm64
ARG FORGEJO_VERSION=6.2.2
ARG FORGEJO_BASE_URL=https://code.forgejo.org/forgejo/runner/releases/download
ADD --chmod=755 ${FORGEJO_BASE_URL}/v${FORGEJO_VERSION}/forgejo-runner-${FORGEJO_VERSION}-linux-arm64 /usr/local/share/forgejo/forgejo-runner

# arm64 forgejo-runner
FROM base_amd64 as forgejo-runner-amd64
ENTRYPOINT ["/usr/local/share/forgejo/forgejo-runner", "daemon"]

