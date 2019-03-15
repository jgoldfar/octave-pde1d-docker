#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

[ -d "./pde1d" ] && rm -rf ./pde1d
git clone -b fixup-build https://github.com/jgoldfar/pde1d.git

# Debian + Octave + PDE1D
DOCKER_REPO_BASE=octave

# Build builder
#IMG_TAG=pdepe
#IMG_TARGET=builder
#docker build -f Dockerfile.debian --target=${IMG_TARGET} -t ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:${IMG_TAG}-${IMG_TARGET} .


# Build main entrypoint
#IMG_TARGET=octave
#docker build -f Dockerfile.debian --target=${IMG_TARGET} -t ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:${IMG_TAG} .
#docker push ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:${IMG_TAG}


# Same as above, with GUI
IMG_TAG=pdepe-gui
docker build -f Dockerfile.gui -t ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:${IMG_TAG} .
docker push ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:${IMG_TAG}

# Alpine + Octave + PDE1D
# Use Docker Hub's infrastructure
#curl -X POST -L https://cloud.docker.com/api/build/v1/source/4813e645-4451-4874-b8d4-88e787c41597/trigger/d09a812d-6a8f-4176-bf23-19141ed9e24e/call/
