FROM alpine:3.22

RUN apk add --no-cache \
    wireguard-tools \
    wireguard-tools-openrc \
    transmission-daemon \
    transmission-daemon-openrc \
    openrc

RUN mkdir -p /etc/wireguard /config/transmission

RUN  ln -s /etc/init.d/wg-quick /etc/init.d/wg-quick.wg

RUN echo "rc_need=wg-quick.wg0" >> /etc/conf.d/transmission-daemon

RUN echo 'net.ipv4.ip_forward=1' > /etc/sysctl.d/ip_forward.conf

RUN rc-update add wg-quick default
RUN rc-update add transmission-daemon default

EXPOSE 9091 51413 51413/udp

CMD ["/sbin/openrc", "--nocolor", "default"]
