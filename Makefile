# Download repositories from git remote
PDE1D_REMOTE:=https://github.com/jgoldfar/pde1d.git
PDE1D_BRANCH:=fixup-build
pde1d/.git:
	git clone -b ${PDE1D_BRANCH} ${PDE1D_REMOTE}

update-pde1d: pde1d/.git
	cd pde1d && git pull --rebase

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
build-pdepe: Dockerfile.debian pde1d/.git update-pde1d
	docker build -f $< -t ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:pdepe .

push-pdepe:
	docker push ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:pdepe

pdepe: build-pdepe push-pdepe

# With-GUI build
build-pdepe-gui: Dockerfile.gui pde1d/.git update-pde1d
	docker build -f $< -t ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:pdepe-gui .

push-pdepe-gui:
	docker push ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:pdepe-gui

pdepe-gui: build-pdepe-gui push-pdepe-gui

# Test target to check operation of PDEPE
PWD:=$(shell pwd)
test-pdepe: test/example1.m
	docker run --rm --workdir /home --volume "${PWD}/test":/home/ ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:pdepe --eval "example1()"

# Run shell with PDEPE image
shell:
	docker run --rm --interactive --tty --workdir /home --volume "${PWD}/test":/home/ --entrypoint /bin/bash ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:pdepe
