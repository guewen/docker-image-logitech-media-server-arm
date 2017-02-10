FROM resin/rpi-raspbian
MAINTAINER Guewen Baconnier <guewen@gmail.com>

ENV SQUEEZEBOX_VERSION 7.9.0
ENV SQUEEZE_VOL /srv/squeezebox
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV PACKAGE_VERSION_URL=http://www.mysqueezebox.com/update/?version=${SQUEEZEBOX_VERSION}&revision=1&geturl=1&os=deb
ENV LIBS_URL=https://github.com/Logitech/slimserver-vendor/archive/public/7.9.zip

COPY bootstrap.pm.patch /tmp/bootstrap.pm.patch

# http://www.imagineict.co.uk/squeezy-pi
RUN apt-get update \
    && apt-get -y --force-yes install curl wget lame libio-socket-ssl-perl tzdata iproute rsync unzip \
              build-essential gcc-4.7 perl libstdc++6-4.7-dev zlib1g-dev yasm libgd-dev \
 && url=$(curl "$PACKAGE_VERSION_URL" | sed 's/_all\.deb/_amd64\.deb/') \
 && curl -Lsf -o /tmp/logitechmediaserver.deb $url \
 && dpkg -i /tmp/logitechmediaserver.deb \
 && cd /tmp \
 && wget -nv $LIBS_URL && unzip 7.9.zip

RUN cd /tmp/slimserver-vendor-public-7.9/CPAN && bash buildme.sh
RUN cd /tmp/slimserver-vendor-public-7.9/faad2 && bash buildme-linux.sh
RUN cd /tmp/slimserver-vendor-public-7.9/flac && bash buildme-linux.sh
RUN cd /tmp/slimserver-vendor-public-7.9/sox && bash buildme-linux.sh
RUN cp -r /tmp/slimserver-vendor-public-7.9/CPAN/build/arch/5.14/arm-linux-gnueabihf-thread-multi-64int /usr/share/squeezeboxserver/CPAN/arch/5.20/ \
 && mv $(tar zxvf /tmp/slimserver-vendor-public-7.9/faad2/faad2-build-armv7l-34091.tgz --wildcards *bin/faad) /usr/share/squeezeboxserver/Bin/arm-linux/ \
 && mv $(tar zxvf /tmp/slimserver-vendor-public-7.9/flac/flac-build-armv7l-34091.tgz --wildcards *bin/flac) /usr/share/squeezeboxserver/Bin/arm-linux/ \
 && mv $(tar zxvf /tmp/slimserver-vendor-public-7.9/sox/sox-build-armv7l-34091.tgz --wildcards *bin/sox) /usr/share/squeezeboxserver/Bin/arm-linux \
 && patch /usr/share/perl5/Slim/bootstrap.pm /tmp/bootstrap.pm.patch \
 && ldconfig \
 && chown -R squeezeboxserver:nogroup /var/lib/squeezeboxserver \
 && rm -rf /tmp/repos /tmp/bootstrap.patch \
 && rm -f /tmp/logitechmediaserver.deb \
 && apt-get remove -y build-essential gcc-4.7 libstdc++6-4.7-dev zlib1g-dev yasm libgd-dev \
 && apt-get clean

RUN mkdir -p /config/etc && mv /etc/timezone /config/etc/ && ln -s /config/etc/timezone /etc/
RUN echo "Europe/Zurich" > /config/etc/timezone

VOLUME $SQUEEZE_VOL
EXPOSE 3483 3483/udp 9000 9090

COPY entrypoint.sh /entrypoint.sh
COPY start-squeezebox.sh /start-squeezebox.sh
RUN chmod 755 /entrypoint.sh /start-squeezebox.sh
ENTRYPOINT ["/entrypoint.sh"]

