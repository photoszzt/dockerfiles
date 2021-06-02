#!/usr/bin/env bash
set -e  # exit on error

if [ -z "$1" ]
  then
    echo "Please specify docker image name as the first argument"
    echo "Usage $0 DOCKER_IMAGE_NAME"
    exit 1
fi

DOCKER_IMAGE=${1}
shift # Consume argument 1
RUN_DOCKER_INTERACTIVE=${RUN_DOCKER_INTERACTIVE:-1}
ROOT_DIR=$(cd "$(dirname "$0")"/../../; pwd)
CACHE_DIR=${CACHE_DIR:-$HOME/.cache/$DOCKER_IMAGE}

DEBUG_FLAGS="--cap-add=SYS_PTRACE --security-opt seccomp=unconfined"
DOCKER_MAP="-v $ROOT_DIR:/source -v $CACHE_DIR/ccache:/root/.ccache"

DOCKER_FLAGS="--rm ${DOCKER_MAP} --ipc=host --security-opt seccomp=unconfined ${DEBUG_FLAGS}"
if [[ ${DOCKER_IMAGE} == *"rocm"* ]]; then
    DOCKER_FLAGS="${DOCKER_FLAGS} --device=/dev/kfd --device=/dev/dri --group-add video"
elif [[ ${DOCKER_IMAGE} == *"cuda"* ]]; then
    DOCKER_FLAGS="${DOCKER_FLAGS} --gpus all"
fi

DOCKER_CMD="docker run -d ${DOCKER_FLAGS} ${DOCKER_IMAGE}"

${DOCKER_CMD} "$@"
