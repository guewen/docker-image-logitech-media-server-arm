#!/bin/bash

docker run --rm --privileged multiarch/qemu-user-static:register --reset
docker build -t guewen/logitech-media-server-arm .
