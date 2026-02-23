#!/bin/sh

echo "=== SECURITY TEST START ==="

echo "\n[1] User Check"
whoami
id

echo "\n[2] Root Write Test"
touch /root/testfile 2>/dev/null && echo "❌ Root writable" || echo "✅ Root not writable"

echo "\n[3] Filesystem Write Test"
touch /etc/testfile 2>/dev/null && echo "❌ /etc writable" || echo "✅ /etc not writable"

echo "\n[4] Direct Internet Test (should FAIL)"
curl -I https://google.com --max-time 5 2>/dev/null && echo "❌ Direct internet works" || echo "✅ Direct internet blocked"

echo "\n[5] Slack Allowed Test (should WORK)"
curl -I https://slack.com --max-time 5 2>/dev/null && echo "✅ Slack reachable" || echo "❌ Slack blocked"

echo "\n[6] Raw TCP Test (should FAIL)"
nc -zv google.com 443 2>/dev/null && echo "❌ Raw TCP works" || echo "✅ Raw TCP blocked"

echo "\n[7] DNS Test (should FAIL if not proxied)"
nslookup google.com 2>/dev/null && echo "❌ DNS resolution works" || echo "✅ DNS blocked"

echo "\n=== SECURITY TEST END ==="


