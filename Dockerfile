ARG TARGETARCH
FROM --platform=$BUILDPLATFORM alpine:latest

# Install necessary packages
RUN apk add --no-cache \
    wireguard-tools \
    wireguard-tools-openrc \
    transmission-daemon

# Enable and start the WireGuard service (wg0) via wg-quick
RUN ln -s /etc/init.d/wg-quick /etc/init.d/wg-quick.wg0
RUN rc-update add wg-quick.wg0
RUN mkdir -p /etc/wireguard
# The wg0 config is expected to be mounted here.

# Transmission configuration
RUN mkdir -p /config/transmission
# All transmission config files are expected to be mounted here.

# Expose Transmission's default port (optional, but good practice)
EXPOSE 9091 51413/tcp 51413/udp

# Entrypoint to ensure OpenRC services are started
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
