SET HOST_IP=192.168.1.10
docker run -it --privileged --rm -e HOST_IP=%HOST_IP% -e DISPLAY=%HOST_IP%:0 -e GIT_USER_NAME="Takahiro Shizuki" -e GIT_USER_EMAIL=shizu@futuregadget.com local/playground
