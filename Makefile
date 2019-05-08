# Find path to this makefile for use in `usage` target.
# See https://stackoverflow.com/questions/18136918/how-to-get-current-relative-directory-of-your-makefile
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(patsubst %/,%,$(dir $(mkfile_path)))

usage:
	@echo "usage: make [-f ${current_dir}/Makefile] [TARGET]"
	@echo ""
	@echo "Valid Targets:"
	@echo "    - update-pde1d: Pull and/or update the correct branch for the local"
	@echo "      pde1d repository"
	@echo "    - run-gui: Open the Octave GUI with the current directory mapped"
	@echo "      to the working directory inside the container. Add the argument"
	@echo "      PKG_PATH=... to mount the given path to /pkg."
	@echo "    - shell: Open a bash shell in the non-gui Octave + PDEPE image"
	@echo "    - build-pdepe-base: Build the base image for Octave + PDEPE"
	@echo "    - push-pdepe-base: Push the above image"
	@echo "    - build-pdepe: Build the non-gui image for Octave + PDEPE"
	@echo "    - push-pdepe: Push the above image"
	@echo "    - test-pdepe: Use the non-gui image to run a simple example script."
	@echo "    - build-pdepe-lbfgs: Build the non-gui image for Octave + PDEPE + L-BFGS-B"
	@echo "    - push-pdepe-lbfgs: Push the above image"
	@echo "    - build-pdepe-gui: Build the GUI image for Octave + PDEPE"
	@echo "    - push-pdepe-gui: Push the above image"

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

# No-GUI build
build-pdepe-lbfgs: Dockerfile.debian update-deps
	docker build --target pdepe-lbfgs -f $< -t ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:pdepe-lbfgs .

push-pdepe-lbfgs:
	docker push ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:pdepe-lbfgs

pdepe-lbfgs: build-pdepe-lbfgs push-pdepe-lbfgs

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

DISPLAY_PATH:=$(patsubst %:0,%,${DISPLAY})
run-gui:
	xhost + && \
	docker run \
       --rm \
       --tty \
       --interactive \
       --name octave \
       -e DISPLAY=host.docker.internal:0 \
       -e QT_GRAPHICSSYSTEM="native" \
       --workdir=/data \
       --volume=${PWD}:/data ${ADD_PKG_PATH}\
       --volume ${DISPLAY_PATH}:/tmp/.X11-unix:rw \
       --entrypoint="" \
       --privileged \
       ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:pdepe-gui \
       octave --gui --traditional --verbose && \
	xhost - || xhost -

# Run shell with PDEPE image
shell:
	docker run \
		--rm \
		--interactive \
		--tty \
		--workdir /home \
		--volume "${PWD}/test":/home/ \
		--entrypoint /bin/bash \
		${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:pdepe
