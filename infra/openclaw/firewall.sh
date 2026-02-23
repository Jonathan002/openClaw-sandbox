#!/bin/sh
set -eu

IPT="iptables"

# Debug version
$IPT -V

# Flush rules
$IPT -F
$IPT -X

# Default DROP all
$IPT -P OUTPUT DROP
$IPT -P INPUT DROP
$IPT -P FORWARD DROP

# Allow loopback
$IPT -A OUTPUT -o lo -j ACCEPT
$IPT -A INPUT  -i lo -j ACCEPT

# Allow DNS ONLY to Docker embedded DNS resolver (needed to resolve "squid")
$IPT -A OUTPUT -p udp -d 127.0.0.11 --dport 53 -j ACCEPT
$IPT -A OUTPUT -p tcp -d 127.0.0.11 --dport 53 -j ACCEPT

# Allow connection to Squid proxy only (by name; DNS above enables this)
$IPT -A OUTPUT -p tcp -d squid --dport 3128 -j ACCEPT

# Allow established connections (conntrack preferred; fallback to state)
if $IPT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT >/dev/null 2>&1; then
  $IPT -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
  $IPT -A INPUT  -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
else
  $IPT -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
  $IPT -A INPUT  -m state --state ESTABLISHED,RELATED -j ACCEPT
fi

# Marker file for healthcheck (tmpfs is writable)
echo "ok" > /tmp/firewall_ready
