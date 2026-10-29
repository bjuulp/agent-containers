# Open Code

## Build Instructions

Use the top level `Makefile` to build this. It builds the shared `agent-base`
image first, then layers this tool on top.

```bash
make open-code
```

You can add more local tools to the container to be installed via `apt-get` by
extending the `LOCAL_TOOLS` list in `base/Dockerfile`, which is the single
source of truth for the shared base image.

## Run Instructions
- Create the following file in `~/.local/bin` and make it executable with `chmod u+x`
- The host mapping to host.docker.internal is there to ensure that a local model running
  on your host can be accessed from the container.
  - If you have a firewall running, remember to make it allow connections from docker to
    the local model.

```bash
#!/usr/bin/env bash

PROJ="$(basename "$(pwd)")"
NAME="opencode-${PROJ}"

mkdir -p "$HOME/.local/state/opencode"
mkdir -p "$HOME/.local/share/opencode"
mkdir -p "$HOME/.config/opencode"

exec docker run --rm --tty --interactive \
  --name "$NAME" \
  --add-host=host.docker.internal:host-gateway \
  -v "$HOME/.local/state/opencode:/home/node/.local/state/opencode" \
  -v "$HOME/.local/share/opencode:/home/node/.local/share/opencode" \
  -v "$HOME/.config/opencode/service.json:/home/node/.config/opencode/service.json" \
  -v "$HOME/.config/opencode/package.json:/home/node/.config/opencode/package.json" \
  -v "$HOME/.config/opencode/package-lock.json:/home/node/.config/opencode/package-lock.json" \
  -v "$HOME/.config/opencode/node_modules:/home/node/.config/opencode/node_modules" \
  -v "$HOME/.config/opencode/AGENTS.md:/home/node/.config/opencode/AGENTS.md" \
  -v "$HOME/.config/opencode/opencode.jsonc:/home/node/.config/opencode/opencode.jsonc:ro" \
  -v "$HOME/.zvec:/home/node/.zvec" \
  -v "$HOME/.codegraph:/home/node/.codegraph" \
  -v "$(pwd):/app" \
  open-code "$@"
```

## GitHub access via a dedicated SSH key

Give the agent its own deploy/user key rather than mounting your whole `~/.ssh`:

```bash
ssh-keygen -t ed25519 -N '' -f ~/.ssh/opencode-agent -C "opencode-agent"
  -v "$HOME/.ssh/opencode-agent:/home/node/.ssh/id_ed25519:ro" \
  -v "$HOME/.ssh/opencode-agent.pub:/home/node/.ssh/id_ed25519.pub:ro"
```

The base image pre-creates `/home/node/.ssh` (owned by `node`, mode 700) with
GitHub's host keys already in `known_hosts`. Without that, Docker would create
the directory as `root:root` when mounting the key files and ssh would fail
with `Failed to add the host to the list of known hosts`.

## References

* [Documentation](https://opencode.ai/docs)
* [Github Repo](https://github.com/sst/opencode)
