#!/bin/sh
set -eu

# Must be root to apply iptables
if [ "$(id -u)" -ne 0 ]; then
  echo "entrypoint must run as root to set iptables" >&2
  exit 1
fi

# Apply firewall rules
/firewall.sh

# Drop to non-root for runtime
exec su-exec 1000:1000 "$@"
