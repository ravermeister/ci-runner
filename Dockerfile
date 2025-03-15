# amd64 base
FROM debian:stable-slim AS base_amd64
ARG FORGEJO_VERSION=6.2.2
ARG FORGEJO_BASE_URL=https://code.forgejo.org/forgejo/runner/releases/download
ADD --chmod=755 ${FORGEJO_BASE_URL}/v${FORGEJO_VERSION}/forgejo-runner-${FORGEJO_VERSION}-linux-amd64 /usr/local/share/forgejo/forgejo-runner
COPY --chmod 755 assets/forgectrl /usr/local/bin/
RUN forgectrl setup

# amd64 forgejo-runner
FROM base_amd64 AS forgejo-runner-amd64
ENTRYPOINT ["forgectrl", "setup"]


# arm64 base
FROM arm64v8/debian:stable-slim AS base_arm64
ARG FORGEJO_VERSION=6.2.2
ARG FORGEJO_BASE_URL=https://code.forgejo.org/forgejo/runner/releases/download
ADD --chmod=755 ${FORGEJO_BASE_URL}/v${FORGEJO_VERSION}/forgejo-runner-${FORGEJO_VERSION}-linux-arm64 /usr/local/share/forgejo/forgejo-runner
COPY --chmod 755 assets/forgectrl /usr/local/bin/
RUN forgectrl setup

# arm64 forgejo-runner
FROM base_amd64 as forgejo-runner-amd64
ENTRYPOINT ["forgectrl", "run"]
