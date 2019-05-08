# Octave+PDE1D docker container

[![Docker Build Status](https://img.shields.io/docker/automated/jgoldfar/octave.svg) ![Docker Pulls](https://img.shields.io/docker/pulls/jgoldfar/octave.svg)](https://hub.docker.com/r/jgoldfar/octave/)
[![Build Status](https://travis-ci.org/jgoldfar/octave-pde1d-docker.svg?branch=master)](https://travis-ci.org/jgoldfar/octave-pde1d-docker)

This repository builds images for [Octave](https://octave.org/) including [pde1d](https://github.com/jgoldfar/pde1d) and [L-BFGS-B](https://github.com/pcarbo/lbfgsb-matlab), primarily for the purposes of running continuous integration processes against MATLAB code.

This project is related to (and builds off of) the [octave-docker](https://github.com/jgoldfar/octave-docker) project.

## Setup

download source dependencies (first time using the package only):

```shell
git submodule update --init --recursive
```

Note: to pull any subsequent updates, run

```shell
git pull --recurse-submodules
```

build:

```shell
make build-pdepe # Run make usage to see other options
```

## Usage

```shell
docker run --rm -i --user="$(id -u):$(id -g)" --net=none -v "$(pwd)":/data jgoldfar/octave:pdepe
```

or

```shell
make [-f /path/to/this/dir/Makefile] shell DOCKER_RUN_IMAGE=pdepe-lbgfs
```
to open a shell in a container with the given image.


Your current working directory should be mounted to `/data` inside the running container.

Why should I use this container?

- Easy setup, reduced need for locally installed dependencies

## Container Descriptions

* `pdepe-lbfgs` contains Octave, pde1d, and [l-bfgs-b](git@github.com:pcarbo/lbfgsb-matlab.git).

* `pdepe` contains an Octave + pde1d installation on top of Debian Stretch-Slim (without any GUI components)

* `pdepe-gui` contains an Octave + pde1d installation on top of Debian Stretch-Slim, including GUI components.

* `pdepe-base` is the image onto which Octave + pde1d is built, and includes Sundials built form source (as required for PDE1D)

## Misc Instructions

To add a git dependency (e.g. L-BFGS-B) from a specific branch to a specific path, run

```shell
git submodule add -b build-on-docker git@github.com:jgoldfar/lbfgsb-matlab.git lbfgsb
```
