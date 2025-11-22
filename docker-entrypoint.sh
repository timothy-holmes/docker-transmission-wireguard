#!/bin/bash

set -e

# Start OpenRC
echo "Starting OpenRC..."
openrc sysinit

# Check for WireGuard config
if [ ! -f "/etc/wireguard/wg0.conf" ]; then
  echo "WireGuard config /etc/wireguard/wg0.conf not found. Skipping WireGuard startup."
else
  echo "Starting WireGuard via OpenRC..."
  rc-service wg-quick start

  # Wait for the service to start
  echo "Waiting for wg-quick service to initialize..."
  WAIT_SECONDS=30
  for i in $(seq 1 $WAIT_SECONDS); do
    if rc-service wg-quick status | grep -q "started"; then
      echo "WireGuard service started successfully."
      break
    fi
    if rc-service wg-quick status | grep -q "crashed"; then
      echo "Error: WireGuard service failed to start (crashed)."
      exit 1
    fi
    sleep 1
    if [ "$i" -eq "$WAIT_SECONDS" ]; then
      echo "Error: Timeout waiting for WireGuard service to start."
      rc-service wg-quick status # Print final status for debugging
      exit 1
    fi
  done
fi

# Transmission configuration and startup
echo "Starting Transmission daemon..."
# Ensure the config directory exists and has correct permissions
mkdir -p /config/transmission
chown -R transmission:transmission /config/transmission

# Run transmission-daemon in the foreground
su - transmission -c "transmission-daemon -g /config/transmission -f"