# Octave+PDE1D docker container

[![Docker Build Status](https://img.shields.io/docker/automated/jgoldfar/octave.svg) ![Docker Pulls](https://img.shields.io/docker/pulls/jgoldfar/octave.svg)](https://hub.docker.com/r/jgoldfar/octave/)
[![Build Status](https://travis-ci.org/jgoldfar/octave-pde1d-docker.svg?branch=master)](https://travis-ci.org/jgoldfar/octave-pde1d-docker)

This repository builds containers for [Octave](https://octave.org/) including [pde1d](https://github.com/jgoldfar/pde1d), primarily for the purposes of running continuous integration processes against MATLAB code.

## Setup

build:

```shell
docker build -t jgoldfar/octave:pdepe -f Dockerfile.debian .
```

## Usage

```shell
docker run --rm -i --user="$(id -u):$(id -g)" --net=none -v "$(pwd)":/data jgoldfar/octave:pdepe
```

Your current working directory should be mounted to `/data` inside the running container.

Why should I use this container?

- Easy setup, reduced need for locally installed dependencies

## Container Descriptions

* `pdepe` contains an Octave+pde1d installation on top of Debian Stretch-Slim (without any GUI components)

* `pdepe-gui` Contains an Octave+pde1d installation on top of Debian Stretch-Slim, including GUI components.
