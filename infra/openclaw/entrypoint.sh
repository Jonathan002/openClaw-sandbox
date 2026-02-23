#!/bin/sh
set -eu

if [ "$(id -u)" -ne 0 ]; then
  echo "entrypoint must run as root to set iptables" >&2
  exit 1
fi

echo "[entrypoint] applying firewall..."
/firewall.sh || {
  echo "[entrypoint] firewall failed. iptables output:" >&2
  iptables -S || true
  echo "[entrypoint] exiting" >&2
  exit 1
}

echo "[entrypoint] firewall applied; dropping to uid 1000"
exec su-exec 1000:1000 "$@"
