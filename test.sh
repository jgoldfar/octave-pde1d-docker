#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Debian + Octave + PDE1D
DOCKER_REPO_BASE=octave
IMG_TAG=pdepe


#echo "Run shell"
#docker run --rm --interactive --tty --workdir /home --volume "$(pwd)/test":/home/ --entrypoint /bin/bash jgoldfar/${DOCKER_REPO_BASE}:${IMG_TAG}

echo "Run PDEPE example"
docker run --rm --workdir /home --volume "$(pwd)/test":/home/ jgoldfar/${DOCKER_REPO_BASE}:${IMG_TAG} --eval "example1()"

