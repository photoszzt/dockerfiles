#!/bin/bash
set -x

SCRIPT_PATH=$(readlink -f $0)
BASE_DIR=$(dirname $SCRIPT_PATH)

docker build --build-arg "USER_UID=$(id -u)" -t photoszzt/ava-cuda-10.1-dev -f Dockerfile.ava-cuda-10.1-dev .
