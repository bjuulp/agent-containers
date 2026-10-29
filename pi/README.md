# Open Code

## Build Instructions

Use the top level `Makefile` to build this. It builds the shared `agent-base`
image first, then layers this tool on top.

```bash
make pi
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
NAME="pi-${PROJ}"

mkdir -p "$HOME/.pi/agent"

exec docker run --rm --tty --interactive \
  --name "$NAME" \
  --add-host=host.docker.internal:host-gateway \
  -v "$HOME/.pi/agent:/home/node/.pi/agent" \
  -v "$HOME/.zvec:/home/node/.zvec" \
  -v "$HOME/.codegraph:/home/node/.codegraph" \
  -v "$(pwd):/app" \
  pi "$@"
```

## GitHub access via a dedicated SSH key

Give the agent its own deploy/user key rather than mounting your whole `~/.ssh`:

```bash
ssh-keygen -t ed25519 -N '' -f ~/.ssh/pi-agent -C "pi-agent"
  -v "$HOME/.ssh/pi-agent:/home/node/.ssh/id_ed25519:ro" \
  -v "$HOME/.ssh/pi-agent.pub:/home/node/.ssh/id_ed25519.pub:ro"
```

The base image pre-creates `/home/node/.ssh` (owned by `node`, mode 700) with
GitHub's host keys already in `known_hosts`. Without that, Docker would create
the directory as `root:root` when mounting the key files and ssh would fail
with `Failed to add the host to the list of known hosts`.

## References

* [Documentation](https://pi.dev/docs/latest)
* [Github Repo](https://github.com/earendil-works/pi)
