# amd64 base
FROM debian:stable-slim AS base_amd64
ARG FORGEJO_VERSION=6.2.2
ARG GO_VERSION=1.24.1

ADD --chmod=755 https://code.forgejo.org/forgejo/runner/releases/download/v${FORGEJO_VERSION}/forgejo-runner-${FORGEJO_VERSION}-linux-amd64 /usr/local/share/forgejo/forgejo-runner
ADD --chmod=755 https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz /tmp/tools/go.tar.gz
COPY --chmod=755 assets/forgectrl /usr/local/bin/
RUN forgectrl setup

# amd64 forgejo-runner
FROM base_amd64 AS forgejo-runner-amd64
ENTRYPOINT ["forgectrl", "run"]


# arm64 base
FROM arm64v8/debian:stable-slim AS base_arm64
ARG FORGEJO_VERSION=6.2.2
ARG GO_VERSION=1.24.1

ADD --chmod=755 https://code.forgejo.org/forgejo/runner/releases/download/v${FORGEJO_VERSION}/forgejo-runner-${FORGEJO_VERSION}-linux-arm64 /usr/local/share/forgejo/forgejo-runner
ADD --chmod=755 https://go.dev/dl/go${GO_VERSION}.linux-arm64.tar.gz /tmp/tools/go.tar.gz
COPY --chmod=755 assets/forgectrl /usr/local/bin/
RUN forgectrl setup

# arm64 forgejo-runner
FROM base_amd64 as forgejo-runner-amd64
ENTRYPOINT ["forgectrl", "run"]
