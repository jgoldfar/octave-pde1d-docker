# Octave+PDE1D docker container

[![Build Octave + PDE1D Images](https://github.com/jgoldfar/octave-pde1d-docker/actions/workflows/build.yml/badge.svg)](https://github.com/jgoldfar/octave-pde1d-docker/actions/workflows/build.yml)
[![Docker Build Status](https://img.shields.io/docker/automated/jgoldfar/octave.svg) ![Docker Pulls](https://img.shields.io/docker/pulls/jgoldfar/octave.svg)](https://hub.docker.com/r/jgoldfar/octave/)

This repository builds images for [Octave](https://octave.org/) including [pde1d](https://github.com/jgoldfar/pde1d) and [L-BFGS-B](https://github.com/pcarbo/lbfgsb-matlab), primarily for the purposes of running continuous integration processes against MATLAB code.

This project builds on [octave-docker](https://github.com/jgoldfar/octave-docker), is minimally maintained, and accepts PRs.

> This program is distributed in the hope that it will be useful,
> but WITHOUT ANY WARRANTY; without even the implied warranty of
> MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

For more information, reach out to the team at [desert.frog.solutions@gmail.com](mailto:desert.frog.solutions@gmail.com) or [desertfrogsolutions.com](https://desertfrogsolutions.com)

## Using Octave + PDE1D

```shell
docker run --rm -i --user="$(id -u):$(id -g)" --net=none -v "$(pwd)":/data jgoldfar/octave:pdepe
```

or

```shell
make [-f /path/to/this/dir/Makefile] shell DOCKER_RUN_IMAGE=pdepe-lbgfs
```
to open a shell in a container with the given image.


Your current working directory will be mounted to `/data` inside the running container.

Why should I use this container?

- Easy setup, reduced need for locally installed dependencies

### Available Images

* `pdepe-lbfgs` contains Octave, pde1d, and [l-bfgs-b](git@github.com:pcarbo/lbfgsb-matlab.git).

* `pdepe` contains an Octave + pde1d installation on top of Debian Bullseye-Slim (without any GUI components)

* `pdepe-gui` contains an Octave + pde1d installation on top of Debian Bullseye-Slim, including GUI components.

## Setup (for building, developing, or improving Octave+PDE1D)

0. The first time you clone this repository, you'll need to download source dependencies:

```shell
git submodule update --init --recursive
```

Note: to pull any subsequent updates, run

```shell
git pull --recurse-submodules
```

or `make update-deps`.

The build process is automated with a self-documenting [Makefile](https://www.gnu.org/software/make/); run

```shell
make
```
to see usage instructions.
