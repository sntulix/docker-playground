#!/bin/bash
SHELL_PATH=$(cd "$(dirname "$0")"; pwd)
docker run -it --rm -v /$SHELL_PATH:/mnt/dockerfile_root -v /$HOME:/home/host_user -p 80:80 -p 5432:5432 -p 139:139 -p 445:445 local/playground
