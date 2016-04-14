#!/bin/sh
SHELL_PATH=$(cd "$(dirname "$0")"; pwd)
docker run -it --rm -v $SHELL_PATH:/mnt/dockerfile_root -v ~/:/home/host_user -p 80:80 -p 5432:5432 local/playground
