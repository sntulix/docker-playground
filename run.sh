#!/bin/bash
SHELL_PATH=$(cd "$(dirname "$0")"; pwd)
#docker run -it --rm -v /$SHELL_PATH:/mnt/dockerfile_root -v /$HOME:/home/host_user -p 8080:8080 -p 5432:5432 -p 139:139 -p 445:445 local/playground
#docker run -it --privileged --rm -e DISPLAY=192.168.1.10:0 -v /$SHELL_PATH:/mnt/dockerfile_root -v /$HOME:/home/host_user -p 8080:8080 local/playground
docker run -it --privileged --rm -e DISPLAY=192.168.1.10:0 -v /$SHELL_PATH:/mnt/dockerfile_root -v /$HOME:/home/host_user local/playground
