# Copilot Instructions – Secure OpenClaw Docker Sandbox

This repository implements a security-first Docker Compose setup for running OpenClaw on macOS (Apple Silicon) with Docker Desktop.

## Security Requirements

All code must prioritize sandboxing and least privilege.

The architecture must enforce:

1. Docker internal network isolation:
   - `openclaw-net` must use `internal: true`
   - OpenClaw container must NOT be attached to any internet-enabled network
   - Only the Squid proxy container may connect to an internet-enabled network

2. Strict outbound egress control:
   - OpenClaw container must have no direct internet route
   - Default iptables policy: DROP
   - Allow only TCP to squid:3128
   - Allow loopback
   - Allow established/related

3. Domain whitelist via Squid:
   - Only allow Slack domains:
     - slack.com
     - hooks.slack.com
   - Only allow HTTPS CONNECT on port 443
   - Deny all other domains

4. Container hardening:
   - cap_drop: ALL
   - cap_add: NET_ADMIN only if required
   - security_opt: no-new-privileges:true
   - read_only: true
   - tmpfs for /tmp
   - Must run as non-root user

5. Security validation:
   - Provide a script that tests:
     - non-root execution
     - read-only filesystem
     - absence of default route
     - blocked raw TCP
     - blocked UDP/DNS
     - blocked ICMP
     - Slack reachable only via proxy
     - all other domains blocked

## Do NOT:
- Attach OpenClaw directly to internet-enabled networks
- Allow 0.0.0.0 exposed ports
- Grant privileged mode
- Add unnecessary capabilities
- Disable security for convenience

Security is prioritized over simplicity.

All generated docker-compose.yml files must include explanatory comments.
