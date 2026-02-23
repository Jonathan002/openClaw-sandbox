package sandbox.squid

# Fail if squid.conf contains domains outside Slack/hook slack.
# This is a lightweight heuristic guardrail.

deny[msg] {
  contains(input, ".google.com")
  msg := "squid.conf must not whitelist google.com"
}

deny[msg] {
  # Allow only slack.com and hooks.slack.com (and comments/whitespace)
  # If someone adds a different dstdomain, fail.
  some line
  lines := split(input, "\n")
  line := lines[_]
  contains(line, "dstdomain")
  not contains(line, ".slack.com")
  not contains(line, ".hooks.slack.com")
  msg := sprintf("squid.conf has a dstdomain line that is not Slack-only: %v", [line])
}
