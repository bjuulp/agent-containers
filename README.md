# agent-containers

A bunch of containerized AI agents with some simple instructions for running them against your local code in slightly
safer ways.

Where possible, how to persist configuration from session to session has been documented as well. As a lot of these
agents store your API credentials _in_ their configuration files, you should be really cautious about checking in config
to some place like your dotfiles repo.

## Prerequisites

You'll need either [Docker](https://www.docker.com/) (preferably running rootless) or [podman](https://podman.io/)
installed on your system to build and launch these containers.

## Building

To build all the containers:

```bash
make all
```

To build any specific container use the directory name. For example:

```bash
make open-code
```

### Architecture

The project uses a multi-stage build approach with a common base image (`agent-base`) that contains shared dependencies
and configuration. Tool-specific images extend this base with their unique requirements:

```
agent-base
├── open-code
└── pi
```

Each Dockerfile uses multi-stage builds to:
- Separate build-time dependencies from runtime dependencies
- Minimize final image sizes by ~20-40%
- Improve security by reducing the attack surface
- Speed up builds through better layer caching

### Build Options

The build system supports caching control options:

```bash
# Build all containers (base, open-code, pi)
make all

# Build just the base image
make base

# Build a specific tool (automatically builds base if needed)
make open-code
```

### Cleaning

To remove built images:

```bash
# Remove images but preserve build cache
make clean
```

## Running

See the README files in the sub-directories for instructions on initial setup, configuration persistence and executing
the AI agents in their container environments.

## Restricted Network Access

If you want to restrict the network access for an agent further so that it can only access a few specific ports on your
host, you can use the following script:

```bash
#! /usr/bin/bash
#
# This script sets up a firewall rule to prevent Docker containers from accessing the host machine, except for a few
# specific ports (8080 and 13305 in this case - the two ports used by Strata and the Lemonade server).

if [ $# -eq 0 ]; then
  nft -f - <<'EOF'
table inet docker_host_access {
  chain input {
    type filter hook input priority -5;
    policy accept;

    # Allow established connections
    ct state established,related accept

    # Allow containers to reach host port 8080
    iifname "docker0" tcp dport 8080 accept
    iifname "docker0" tcp dport 13305 accept

    # Drop all other traffic from containers to the host
    iifname "docker0" drop
   }
}
EOF
elif [ "$1" == "-d" ]; then
  nft delete table inet docker_host_access
else
  echo "Usage: $0 [-d]"
  echo "  -d: Delete the firewall rules, otherwise it will create them."
fi
```

