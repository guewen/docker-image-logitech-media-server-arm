FROM resin/rpi-raspbian
MAINTAINER Lars Kellogg-Stedman <lars@oddbit.com>

ENV SQUEEZEBOX_VERSION 7.9.0
ENV SQUEEZE_VOL /srv/squeezebox
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV PACKAGE_VERSION_URL=http://www.mysqueezebox.com/update/?version=${SQUEEZEBOX_VERSION}&revision=1&geturl=1&os=deb

COPY bootstrap.pm.patch /tmp/bootstrap.pm.patch

# http://www.imagineict.co.uk/squeezy-pi
RUN apt-get update && \
	apt-get -y --force-yes install curl wget lame libio-socket-ssl-perl tzdata iproute \
              build-essential gcc-4.7 perl libstdc++6-4.7-dev && \
	url=$(curl "$PACKAGE_VERSION_URL" | sed 's/_all\.deb/_amd64\.deb/') && \
	curl -Lsf -o /tmp/logitechmediaserver.deb $url && \
	dpkg -i /tmp/logitechmediaserver.deb \
 && cd /tmp \
 # the pipe to wc -l is there to inhibit wget errors because there is a 404 on a file
 && wget -r -np -nH -nv –cut-dirs=6 -R index.html http://svn.slimdevices.com/repos/slim/7.8/trunk/vendor/ | wc -l

RUN cd /tmp/repos/slim/7.8/trunk/vendor/CPAN \
 && bash buildme.sh

RUN cd faad2 && bash buildme-linux.sh && cd .. \
 && cd flac && bash buildme-linux.sh && cd .. \
 && cd sox && bash buildme-linux.sh && cd .. \
 && cd .. \
 && cp -r CPAN/build/arch/5.14/arm-linux-gnueabihf-thread-multi-64int /usr/share/squeezeboxserver/CPAN/arch/5.14/ \
 && mv $(tar zxvf faad2/faad2-build-armv7l-34091.tgz --wildcards *bin/faad) /usr/share/squeezeboxserver/Bin/arm-linux/ \
 && mv $(tar zxvf flac/flac-build-armv7l-34091.tgz --wildcards *bin/flac) /usr/share/squeezeboxserver/Bin/arm-linux/ \
 && mv $(tar zxvf sox/sox-build-armv7l-34091.tgz --wildcards *bin/sox) /usr/share/squeezeboxserver/Bin/arm-linux \
 && patch /usr/share/perl5/Slim/bootstrap.pm /tmp/bootstrap.pm.patch \
 && ldconfig \
 && rm /tmp/bootstrap.patch \\
 && rm -rf /tmp/repos /tmp/bootstrap.patch \\
	&& rm -f /tmp/logitechmediaserver.deb && \
  apt-get remove -y build-essential gcc-4.7 libstdc++6-4.7-dev && \
	apt-get clean


RUN mkdir -p /config/etc && mv /etc/timezone /config/etc/ && ln -s /config/etc/timezone /etc/
RUN echo "Europe/Zurich" > /config/etc/timezone

VOLUME $SQUEEZE_VOL
EXPOSE 3483 3483/udp 9000 9090

COPY entrypoint.sh /entrypoint.sh
COPY start-squeezebox.sh /start-squeezebox.sh
RUN chmod 755 /entrypoint.sh /start-squeezebox.sh
ENTRYPOINT ["/entrypoint.sh"]

