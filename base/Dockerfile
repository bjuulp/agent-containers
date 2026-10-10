# Build stage
FROM node:26-slim

ARG TARGETARCH

# Single source of truth for apt-installed tooling. Override per-build with:
#   docker build --build-arg LOCAL_TOOLS="..." -f base/Dockerfile base
ARG LOCAL_TOOLS="git curl jq ripgrep vim nano make zip unzip ssh-client wget tree imagemagick ca-certificates gnupg procps build-essential python3 python3-pip redis-tools"

# Install System Dependencies (as root)
RUN apt-get update && \
  apt-get install -y --no-install-recommends ${LOCAL_TOOLS} && \
  rm -rf /var/lib/apt/lists/*

# Configure the existing 'node' user
# The node image usually creates the node user. We ensure it owns the app dir.
# Remap 'node' to the host user's UID/GID so bind-mounted host dirs
# (~/.local/share/opencode, project dirs, ...) are writable inside the container.
# Defaults keep the stock 1000:1000; the Makefile passes `id -u`/`id -g`.
# Must run before `USER node` so all later layers are owned by the new UID.
ARG HOST_UID=1000
ARG HOST_GID=1000
RUN set -eux; \
    test "$HOST_UID" != 0 || { echo "HOST_UID=0 not allowed (don't build with sudo)" >&2; exit 1; }; \
    if [ "$(id -u node)" != "$HOST_UID" ] || [ "$(id -g node)" != "$HOST_GID" ]; then \
      groupmod -o -g "$HOST_GID" node; \
      usermod -o -u "$HOST_UID" -g "$HOST_GID" node; \
      chown -R node:node /home/node; \
    fi
WORKDIR /app
RUN chown -R node:node /app

USER node

# Configure NPM global location for the 'node' user
# This allows npm install -g without root permissions
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH=$NPM_CONFIG_PREFIX/bin:$PATH

# User environment configuration
RUN mkdir -p /home/node/.npm-global && \
  npm config set prefix /home/node/.npm-global && \
  echo '' >> /home/node/.bashrc && \
  echo 'export PATH=/home/node/.local/bin:/home/node/.npm-global/bin:$PATH' >> /home/node/.bashrc

# SSH dir must exist and be owned by 'node' before any key files are bind-mounted
# into it; otherwise Docker creates it as root:root and ssh cannot write known_hosts.
# Pre-seed GitHub's host keys so the first non-interactive git/ssh call succeeds.
RUN mkdir -p /home/node/.ssh && chmod 700 /home/node/.ssh
RUN touch /home/node/.ssh/known_hosts
RUN chmod 600 /home/node/.ssh/known_hosts

# Copy bash aliases
COPY ./.bash_aliases /home/node/.bash_aliases

# Global pnpm config (see pnpm-config.yaml for rationale)
COPY --chown=node:node ./pnpm-config.yaml /home/node/.config/pnpm/config.yaml

# Install the zvec-grep MCP
RUN npm install -g @zvec/zvec-grep

# This is a base image, not meant to be run directly
CMD ["/bin/bash"]
