# Find path to this makefile for use in `usage` target.
# See https://stackoverflow.com/questions/18136918/how-to-get-current-relative-directory-of-your-makefile
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(patsubst %/,%,$(dir $(mkfile_path)))

usage:
	@echo "usage: make [-f ${current_dir}/Makefile] [TARGET]"
	@echo ""
	@echo "Valid Targets:"
	@echo " Container Management:"
	@echo "    - run-gui: Open the Octave GUI with the current directory mapped"
	@echo "      to the working directory inside the container. Add the argument"
	@echo "      PKG_PATH=... to mount the given path to /pkg."
	@echo "    - run-shell: Open a bash shell in the non-gui Octave image."
	@echo "      To change the image, set DOCKER_RUN_TAG=.... Default: ${DOCKER_RUN_TAG}"
	@echo "    - run-script: Run a script using the image with DOCKER_RUN_TAG."
	@echo "      Default script: DOCKER_RUN_SCRIPT=${DOCKER_RUN_SCRIPT}."
	@echo "    - run-command: Run/evaluate a given command in Octave."
	@echo "      Default command: DOCKER_RUN_COMMAND=${DOCKER_RUN_COMMAND}."
	@echo " By default, the run-script and run-command targets call octave with the"
	@echo " arguments OCTAVE_RUN_ARGS=${OCTAVE_RUN_ARGS}."
	@echo " To modify the name given to the container, set DOCKER_CONTAINER_NAME=..."
	@echo " By default, DOCKER_CONTAINER_NAME=${DOCKER_CONTAINER_NAME}"
	@echo " Image Generation:"
	@echo "    - build-pdepe-base: Build the base image for Octave + PDEPE"
	@echo "    - push-pdepe-base: Push the above image"
	@echo "    - build-pdepe: Build the non-gui image for Octave + PDEPE"
	@echo "    - push-pdepe: Push the above image"
	@echo "    - build-pdepe-lbfgs: Build the non-gui image for Octave + PDEPE + L-BFGS-B"
	@echo "    - push-pdepe-lbfgs: Push the above image"
	@echo "    - build-pdepe-gui: Build the GUI image for Octave + PDEPE"
	@echo "    - push-pdepe-gui: Push the above image"
	@echo " Utility:"
	@echo "    - test-pdepe: Use the non-gui image to run a simple example script."
	@echo "    - update-pde1d: Pull and/or update the correct branch for the local"
	@echo "      pde1d repository"

## Update dependencies
update-deps:
	git pull --recurse-submodules

## Recipes for image build
DOCKER_USERNAME?=jgoldfar
DOCKER_REPO_BASE?=octave


# Base Image for PDEPE/PDE1D
build-pdepe-base: Dockerfile.base
	docker build -f $< -t ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:pdepe-base .

push-pdepe-base:
	docker push ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:pdepe-base

pdepe-base: build-pdepe-base push-pdepe-base


# No-GUI build
build-pdepe: Dockerfile.debian update-deps
	docker build --target pdepe -f $< -t ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:pdepe .

push-pdepe:
	docker push ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:pdepe

pdepe: build-pdepe push-pdepe


# No-GUI build, with LBFGS
build-pdepe-lbfgs: Dockerfile.debian update-deps
	docker build --target pdepe-lbfgs -f $< -t ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:pdepe-lbfgs .

push-pdepe-lbfgs:
	docker push ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:pdepe-lbfgs

pdepe-lbfgs: build-pdepe-lbfgs push-pdepe-lbfgs


# No-GUI build, with LBFGS and Odepkg
build-pdepe-lbfgs-odepkg: Dockerfile.debian update-deps
	docker build --target pdepe-lbfgs-odepkg -f $< -t ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:pdepe-lbfgs-odepkg .

push-pdepe-lbfgs-odepkg:
	docker push ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:pdepe-lbfgs-odepkg

pdepe-lbfgs-odepkg: build-pdepe-lbfgs-odepkg push-pdepe-lbfgs-odepkg


# With-GUI build
build-pdepe-gui: Dockerfile.gui update-deps
	docker build --target pdepe-gui -f $< -t ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:pdepe-gui .

push-pdepe-gui:
	docker push ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:pdepe-gui

pdepe-gui: build-pdepe-gui push-pdepe-gui

# Test target to check operation of PDEPE
PWD:=$(shell pwd)
test-pdepe: test/example1.m
	docker run --rm --workdir /home --volume "${PWD}/test":/home/ ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:pdepe --eval "example1()"

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
run-gui:
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
       ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:${DOCKER_RUN_TAG} \
       octave --gui --traditional --verbose && \
	xhost - || xhost -

# Run shell with PDEPE image
run-shell:
	docker run \
		--rm \
		--interactive \
		--tty \
		--net=none \
		--workdir /data \
		--user="${DOCKER_RUN_USER}" \
		--volume "${PWD}":/data \
		--entrypoint /bin/bash \
		${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:${DOCKER_RUN_TAG}

# Arguments for octave inside the container for run-script and
# run-command:
OCTAVE_RUN_ARGS?=--no-gui --no-window-system --no-line-editing --traditional --verbose

# Run Main.m file
DOCKER_RUN_SCRIPT?=Main.m
run-script: ${PWD}/${DOCKER_RUN_SCRIPT}
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
       ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:${DOCKER_RUN_TAG} \
       octave ${OCTAVE_RUN_ARGS} ${DOCKER_RUN_SCRIPT}

DOCKER_RUN_COMMAND?=
ifeq (${DOCKER_RUN_COMMAND},)
run-command:
	@echo "Usage: make -f ${current_dir}/Makefile $@ DOCKER_RUN_COMMAND=\"...\""
else
run-command:
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
       ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:${DOCKER_RUN_TAG} \
       octave ${OCTAVE_RUN_ARGS} --eval "${DOCKER_RUN_COMMAND}"
endif
