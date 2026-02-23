#!/bin/sh

# Prefer legacy iptables if present (helps on some CI kernels)
if command -v iptables-legacy >/dev/null 2>&1; then
  alias iptables=iptables-legacy
fi

set -eu

# Flush rules
iptables -F
iptables -X

# Default DROP all
iptables -P OUTPUT DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP

# Allow loopback
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

# Allow DNS ONLY to Docker embedded DNS resolver (needed to resolve "squid")
iptables -A OUTPUT -p udp -d 127.0.0.11 --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp -d 127.0.0.11 --dport 53 -j ACCEPT

# Allow connection to Squid proxy only (by name; DNS above enables this)
iptables -A OUTPUT -p tcp -d squid --dport 3128 -j ACCEPT

# Allow established connections
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT  -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
