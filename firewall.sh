#!/bin/sh

# Install tools
apk add --no-cache iptables curl busybox-extras

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

# Allow connection to Squid proxy only
iptables -A OUTPUT -p tcp -d squid --dport 3128 -j ACCEPT

# Allow established connections
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Start idle process
sleep infinity
