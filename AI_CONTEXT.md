# OpenClaw Secure Docker Setup (Mac Mini)

## Goal
Build a hardened Docker Compose setup on macOS (Apple Silicon) that runs OpenClaw with:
- Host OS hardened (macOS + Little Snitch)
- Container cannot access the internet directly via any protocol (TCP/UDP/ICMP/DNS)
- Container may only reach internet through a Squid proxy
- Squid proxy uses domain whitelist: Slack only (slack.com + hooks.slack.com) over HTTPS (CONNECT 443)
- OpenClaw container should be non-root at runtime
- Root filesystem read-only, writable tmpfs for /tmp
- no-new-privileges enabled
- cap_drop ALL; cap_add NET_ADMIN only if needed for iptables inside container
- Prefer security over simplicity

## Desired architecture
- Docker network `openclaw-net` is `internal: true`
- OpenClaw container attached ONLY to `openclaw-net` (no route to internet)
- Squid attached to both `openclaw-net` and `internet-net` (default NAT-enabled)
- OpenClaw uses HTTP_PROXY/HTTPS_PROXY pointing to squid:3128
- iptables inside OpenClaw container:
  - default DROP INPUT/OUTPUT/FORWARD
  - allow loopback
  - allow only TCP to squid:3128
  - allow established/related

## Required deliverables
1) docker-compose.yml with comments
2) squid.conf with comments (Slack whitelist only)
3) firewall.sh (iptables) with comments
4) security-test.sh that validates:
   - non-root user
   - read-only filesystem (writes fail to /etc, /root)
   - no default route to internet (ip route)
   - direct HTTP/HTTPS without proxy fails
   - raw TCP to internet fails
   - UDP (DNS) fails
   - ping/ICMP fails
   - Slack HTTPS via proxy succeeds
5) Instructions in README.md for running + testing on macOS Docker Desktop

## Notes
- Docker Desktop is installed and working on Apple Silicon.
- Little Snitch is used on host but cannot differentiate container traffic; container egress is enforced inside Docker using internal networks + iptables + squid.
- Use curl, nc, nslookup/drill, ping for tests.
