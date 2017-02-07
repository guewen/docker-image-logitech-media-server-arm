# Docker Container for Logitech Media Server

This is a Docker image for running the Logitech Media Server package
(aka SqueezeboxServer) on ARM.

Run Directly:

    docker run -d \
               -p 9000:9000 \
               -p 3483:3483 \
               -p 3483:3483/udp \
               -v <local-state-dir>:/srv/squeezebox \
               -v <audio-dir>:/srv/music \
               larsks/logitech-media-server

The original author is Lars Kellogg-Stedman <lars@oddbit.com> (https://github.com/larsks/docker-image-logitech-media-server). This is the ARM port.

