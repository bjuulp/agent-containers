# agent-containers

A bunch of container-ed AI agents with some simple instructions for running
them against your local code in slightly safer ways.

Where possible, I've documented how to persist configuration from session to
session as well. As a lot of these agents store your API credentials _in_ their
configuration files, you should be really cautious about checking in config to
some place like your dotfiles repo.

## Prerequisites

You'll need either [Docker](https://www.docker.com/) (preferably running
rootless) or [podman](https://podman.io/) installed on your system to build and
launch these containers.

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

The project uses a multi-stage build approach with a common base image
(`agent-base`) that contains shared dependencies and configuration.
Tool-specific images extend this base with their unique requirements:

```
agent-base
├── claude-code
├── open-code
└── openai-codex
```

Each Dockerfile uses multi-stage builds to:
- Separate build-time dependencies from runtime dependencies
- Minimize final image sizes by ~20-40%
- Improve security by reducing the attack surface
- Speed up builds through better layer caching

### Build Options

The build system supports caching control options:

```bash
# Build all containers (base, claude-code, open-code, openai-codex)
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

See the README files in the sub-directories for instructions on initial setup,
configuration persistence and executing the AI agents in their container
environments.

