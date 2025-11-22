FROM alpine:3.22

RUN apk add --no-cache \
    wireguard-tools \
    wireguard-tools-openrc \
    transmission-daemon \
    transmission-daemon-openrc \
    openrc

RUN mkdir -p /etc/wireguard /config/transmission

RUN  ln -s /etc/init.d/wg-quick /etc/init.d/wg-quick.wg

ENV WG_CONFIG_NAME=wg0

RUN echo "rc_need=wg-quick.${WG_CONFIG_NAME}" >> /etc/conf.d/transmission-daemon

RUN echo 'net.ipv4.ip_forward=1' > /etc/sysctl.d/ip_forward.conf
RUN echo 'net.ipv6.conf.all.forwarding=1' >> /etc/sysctl.d/ip_forward.conf
RUN echo 'net.ipv6.conf.default.forwarding=1' >> /etc/sysctl.d/ip_forward.conf

RUN rc-update add wg-quick default
RUN rc-update add transmission-daemon default

EXPOSE 9091

VOLUME [ “/sys/fs/cgroup” ]

CMD ["/sbin/openrc", "--nocolor", "default"]
