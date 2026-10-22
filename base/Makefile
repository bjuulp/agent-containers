.PHONY: all ca-certificates

# Note: the apt tool list lives in base/Dockerfile (LOCAL_TOOLS ARG), which is
# the single source of truth. Add tools there, not here.

ca-certificates:
	mkdir -p tmp/ca-certificates
	cp /usr/local/share/ca-certificates/*.crt tmp/ca-certificates/.
