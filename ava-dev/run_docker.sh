#!/usr/bin/env bash
set -e  # exit on error
set -x

if [ -z "$1" ]
  then
    echo "Please specify docker image name as the first argument"
    echo "Usage $0 DOCKER_IMAGE_NAME"
    exit 1
fi

for last; do true; done
DOCKER_IMAGE=$last
CACHE_DIR=${CACHE_DIR:-$HOME/.cache/$DOCKER_IMAGE}

DEBUG_FLAGS="--cap-add=SYS_PTRACE --security-opt seccomp=unconfined"
DOCKER_MAP="-v $CACHE_DIR/ccache:/home/ubuntu/.ccache"

DOCKER_FLAGS="--rm ${DOCKER_MAP} --ipc=host --security-opt seccomp=unconfined ${DEBUG_FLAGS}"
if [[ ${DOCKER_IMAGE} == *"rocm"* ]]; then
    DOCKER_FLAGS="${DOCKER_FLAGS} --device=/dev/kfd --device=/dev/dri --group-add video"
elif [[ ${DOCKER_IMAGE} == *"cuda"* ]]; then
    DOCKER_FLAGS="${DOCKER_FLAGS} --gpus all"
fi

DOCKER_CMD="docker run -d ${DOCKER_FLAGS}"

${DOCKER_CMD} "$@"
