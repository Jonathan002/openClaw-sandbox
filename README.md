# 🔐 Secure OpenClaw Docker Sandbox (Mac Mini – Apple Silicon)

This project runs OpenClaw inside a hardened Docker sandbox with:

- Internal-only Docker network
- Squid proxy with Slack-only domain whitelist
- Full egress lockdown (no direct internet access)
- iptables default DROP policy
- Non-root container execution
- Read-only root filesystem
- Capability minimization (cap_drop ALL + NET_ADMIN only)
- Security audit script

---

# 🏗 Architecture

Mac (Little Snitch enabled)
    ↓
Docker Desktop (Linux VM)
    ↓
openclaw container (internal-only network)
    ↓
squid proxy container (whitelisted Slack domains only)
    ↓
Internet

OpenClaw cannot:
- Access the internet directly
- Use raw TCP
- Use UDP/DNS
- Use ICMP
- Bypass proxy
- Write to system directories
<!-- Other security TODOs: -->
<!-- Prevnet DNS subdomain issues (iptable block port 53 for UDP and TCP fallback) -->


Only Slack HTTPS (CONNECT 443) is allowed via proxy.

---

# 📦 Requirements

- macOS (Apple Silicon)
- Docker Desktop installed and running
- Node.js (only for npm scripts convenience)

---

# 🚀 Quick Start

### 1️⃣ Install dependencies (if Node not installed)

```bash
npm install