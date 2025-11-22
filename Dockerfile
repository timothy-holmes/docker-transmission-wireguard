FROM alpine:3.22

RUN apk add --no-cache \
    wireguard-tools \
    wireguard-tools-openrc \
    transmission-daemon \
    transmission-daemon-openrc \
    openrc \
    ip6tables

RUN sed -i '/getty/d' /etc/inittab
VOLUME ["/sys/fs/cgroup"]

RUN sed -i 's|\[\[ $proto == -4 \]\] && cmd sysctl -q net\.ipv4\.conf\.all\.src_valid_mark=1|[[ $proto == -4 ]] \&\& [[ $(sysctl -n net.ipv4.conf.all.src_valid_mark) != 1 ]] \&\& cmd sysctl -q net.ipv4.conf.all.src_valid_mark=1|' /usr/bin/wg-quick

RUN mkdir -p /etc/wireguard /config/transmission

RUN  ln -s /etc/init.d/wg-quick /etc/init.d/wg-quick.wg0

RUN echo "rc_need=wg-quick.wg0" >> /etc/conf.d/transmission-daemon

RUN echo 'net.ipv4.ip_forward=1' > /etc/sysctl.d/wg.conf
RUN echo 'net.ipv6.conf.all.forwarding=1' >> /etc/sysctl.d/wg.conf
RUN echo 'net.ipv6.conf.default.forwarding=1' >> /etc/sysctl.d/wg.conf
RUN echo 'net.ipv4.conf.all.src_valid_mark=1' >> /etc/sysctl.d/wg.conf

RUN rc-update add wg-quick.wg0 default
RUN rc-update add transmission-daemon default

EXPOSE 9091


CMD ["/sbin/init"]
