# amd64 base
From debian:stable-slim as base_amd64
ARG FORGEJO_VERSION=6.2.2
ARG FORGEJO_BASE_URL=https://code.forgejo.org/forgejo/runner/releases/download
ADD --chmod=755 ${FORGEJO_BASE_URL}/v${FORGEJO_VERSION}/forgejo-runner-${FORGEJO_VERSION}-linux-amd64 /usr/local/share/forgejo/forgejo-runner
COPY --chmod 755 assets/container-nit
RUN
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


# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update