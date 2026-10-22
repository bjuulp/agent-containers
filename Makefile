.PHONY: all clean base open-code pi ca-certificates

# Determine container engine (podman or docker)
CONTAINER_ENGINE := $(shell which podman 2>/dev/null || which docker 2>/dev/null)

# UID/GID of the in-container 'codeuser' user. Defaults to the builder's, so
# bind-mounted host dirs are writable. Override: make open-code HOST_UID=1000
HOST_UID ?= $(shell id -u)
HOST_GID ?= $(shell id -g)

# Note: the apt tool list lives in base/Dockerfile (LOCAL_TOOLS ARG), which is
# the single source of truth. Add tools there, not here.

# Ensure we have a container engine
ifeq ($(CONTAINER_ENGINE),)
$(error No container engine (podman/docker) found in PATH)
endif

all: base open-code pi

ca-certificates:
	make -C base

base: ca-certificates
	@echo "Building base image"
	$(CONTAINER_ENGINE) build \
		--build-arg HOST_UID=$(HOST_UID) \
		--build-arg HOST_GID=$(HOST_GID) \
		-t agent-base \
		-f base/Dockerfile base

open-code: base
	@echo "Building open-code"
	$(CONTAINER_ENGINE) build \
		--no-cache \
		-t open-code \
		-f open-code/Dockerfile open-code

pi: base
	@echo "Building pi"
	$(CONTAINER_ENGINE) build \
		--no-cache \
		-t pi \
		-f pi/Dockerfile pi

clean:
	@echo "Removing container images"
	@for image in open-code pi agent-base; do \
		if $(CONTAINER_ENGINE) image inspect $$image > /dev/null 2>&1; then \
			echo "Removing $$image"; \
			$(CONTAINER_ENGINE) rmi -f $$image; \
	else \
			echo "Image $$image does not exist, skipping"; \
		fi; \
	done
