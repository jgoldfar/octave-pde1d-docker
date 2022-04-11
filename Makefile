# Find path to this makefile for use in `usage` target.
# See https://stackoverflow.com/questions/18136918/how-to-get-current-relative-directory-of-your-makefile
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(patsubst %/,%,$(dir $(mkfile_path)))

# Print usage message (this must be first to avoid running something else when running
# `make` with no arguments on non-compliant Make variants)
usage:
	@echo "Usage: make [target] [VAR=VALUE...]"
	@echo "This Makefile defines automations and processes associated with a given"
	@echo "target."
	@echo "For detailed documentation, look to the Makefile."
	@echo ""
	@echo "Targets:"
	@$(MAKE) help 2>/dev/null
	@echo "Defaults: "
	@echo "  DOCKER_RUN_TAG=${DOCKER_RUN_TAG}"
	@echo "  DOCKER_RUN_SCRIPT=${DOCKER_RUN_SCRIPT}"
	@echo "  DOCKER_RUN_COMMAND=${DOCKER_RUN_COMMAND}"
	@echo "  DOCKER_CONTAINER_NAME=${DOCKER_CONTAINER_NAME}"
	@echo "  OCTAVE_RUN_ARGS=${OCTAVE_RUN_ARGS}"
	@echo " By default, the run-script and run-command targets call octave with the arguments OCTAVE_RUN_ARGS."
	@echo " To modify the name given to the container, set DOCKER_CONTAINER_NAME=..."
# PHONY targets aren't considered to depend on anything, so they will always be generated.
# or run.
.PHONY: usage
# Set usage message to run when the user enters `make`
.DEFAULT_GOAL:=usage

## Autogenerate Help Info
# Borrowed from https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
# Any target with two comment symbols is listed.
.PHONY: help
help: ## Display this help section
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-38s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

## Update dependencies (i.e. submodules)
update-deps: ## Update dependencies (i.e. submodules)
	git pull --recurse-submodules

## Recipes for image build
DOCKER_USER?=jgoldfar
REPO_NAME?=octave


# Base Image for PDEPE/PDE1D
build-pdepe-base: Dockerfile.base ## Build the base image for Octave + PDEPE
	docker build -f $< -t ${DOCKER_USER}/${REPO_NAME}:pdepe-base .


# No-GUI build
build-pdepe: Dockerfile.base Dockerfile.debian ## Build the non-gui image for Octave + PDEPE
	cat $^ | docker build --target pdepe -f - -t ${DOCKER_USER}/${REPO_NAME}:pdepe .

# No-GUI build, with LBFGS
build-pdepe-lbfgs: Dockerfile.base Dockerfile.debian ## Build the non-gui image for Octave + PDEPE + L-BFGS-B
	cat $^ | docker build --target pdepe-lbfgs -f - -t ${DOCKER_USER}/${REPO_NAME}:pdepe-lbfgs .

# With-GUI build
build-pdepe-gui: Dockerfile.base Dockerfile.gui ## Build the GUI image for Octave + PDEPE
	cat $^ | docker build --target pdepe-gui -f - -t ${DOCKER_USER}/${REPO_NAME}:pdepe-gui .


# Test target to check operation of PDEPE
PWD:=$(shell pwd)
test-pdepe: test/example1.m ## Use the non-gui image to run a simple example script.
	docker run --rm --workdir /home --volume "${PWD}/test":/home/ ${DOCKER_USER}/${REPO_NAME}:pdepe --eval "example1()"

# host.docker.internal:0
PKG_PATH?=
ADD_PKG_PATH:=
ifneq (${PKG_PATH},)
ADD_PKG_PATH+=--volume=${PKG_PATH}:/pkg
endif

DOCKER_CONTAINER_NAME?=octave${RANDOM}
# Tag to use when running examples/scripts/etc.
DOCKER_RUN_TAG?=pdepe-gui
# User information to pass to docker container
DOCKER_RUN_USER:=$(shell id -u):$(shell id -g)
# Display path for X11
DISPLAY_PATH:=$(patsubst %:0,%,${DISPLAY})
run-gui: ## Open the Octave GUI with the current directory mapped to the working directory inside the container. Add the argument PKG_PATH=... to mount the given path to /pkg
	docker kill ${DOCKER_CONTAINER_NAME} || echo "Container not yet running."
	xhost + && \
	docker run \
	   --rm \
	   --tty \
	   --interactive \
	   --name ${DOCKER_CONTAINER_NAME} \
	   --user="${DOCKER_RUN_USER}" \
	   -e DISPLAY=host.docker.internal:0 \
	   -e QT_GRAPHICSSYSTEM="native" \
	   -e LIBGL_DEBUG=verbose \
	   --workdir=/data \
	   --volume=${PWD}:/data ${ADD_PKG_PATH}\
	   --volume ${DISPLAY_PATH}:/tmp/.X11-unix:rw \
	   --entrypoint="" \
	   --privileged \
	   ${DOCKER_USER}/${REPO_NAME}:${DOCKER_RUN_TAG} \
	   octave --gui --traditional --verbose && \
	xhost - || xhost -

run-shell: ## Open a bash shell in the non-gui Octave image. To change the image, set DOCKER_RUN_TAG=....
	docker run \
		--rm \
		--interactive \
		--tty \
		--net=none \
		--workdir /data \
		--user="${DOCKER_RUN_USER}" \
		--volume "${PWD}":/data \
		--entrypoint /bin/bash \
		${DOCKER_USER}/${REPO_NAME}:${DOCKER_RUN_TAG}

# Arguments for octave inside the container for run-script and
# run-command:
OCTAVE_RUN_ARGS?=--no-gui --no-window-system --no-line-editing --traditional --verbose

# Run Main.m file
DOCKER_RUN_SCRIPT?=Main.m
run-script: ${PWD}/${DOCKER_RUN_SCRIPT} ## Run DOCKER_RUN_SCRIPT using the image with DOCKER_RUN_TAG.
	docker kill ${DOCKER_CONTAINER_NAME} || echo "Container not yet running."
	docker run \
	   --rm \
	   --tty \
	   --name ${DOCKER_CONTAINER_NAME} \
	   --workdir=/data \
	   --user="${DOCKER_RUN_USER}" \
	   --volume=${PWD}:/data ${ADD_PKG_PATH}\
	   --entrypoint="" \
	   --privileged \
	   ${DOCKER_USER}/${REPO_NAME}:${DOCKER_RUN_TAG} \
	   octave ${OCTAVE_RUN_ARGS} ${DOCKER_RUN_SCRIPT}

DOCKER_RUN_COMMAND?=
ifeq (${DOCKER_RUN_COMMAND},)
run-command: ## run-command: Run/evaluate command DOCKER_RUN_COMMAND in Octave.
	@echo "Usage: make -f ${current_dir}/Makefile $@ DOCKER_RUN_COMMAND=\"...\""
else
run-command: ## run-command: Run/evaluate command DOCKER_RUN_COMMAND in Octave.
	docker kill ${DOCKER_CONTAINER_NAME} || echo "Container not yet running."
	docker run \
	   --rm \
	   --tty \
	   --name ${DOCKER_CONTAINER_NAME} \
	   --workdir=/data \
	   --user="${DOCKER_RUN_USER}" \
	   --volume=${PWD}:/data ${ADD_PKG_PATH}\
	   --entrypoint="" \
	   --privileged \
	   ${DOCKER_USER}/${REPO_NAME}:${DOCKER_RUN_TAG} \
	   octave ${OCTAVE_RUN_ARGS} --eval "${DOCKER_RUN_COMMAND}"
endif
