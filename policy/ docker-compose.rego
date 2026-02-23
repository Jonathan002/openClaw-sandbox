package sandbox.compose

# Conftest passes docker-compose.yml as input (a JSON object)
# We'll use strong invariants that prevent weakening fixes.

deny[msg] {
  # openclaw/openclaw-test service must exist
  not input.services.openclaw
  not input.services["openclaw-test"]
  msg := "Missing service: openclaw (or openclaw-test). Expected a sandboxed app service."
}

# Helper to pick the service name you use
svc_name := name {
  input.services.openclaw
  name := "openclaw"
} else := name {
  input.services["openclaw-test"]
  name := "openclaw-test"
}

svc := input.services[svc_name]

########################################
# Invariants: network isolation
########################################

deny[msg] {
  # openclaw-net must exist and must be internal true
  not input.networks["openclaw-net"]
  msg := "Network openclaw-net is missing."
}

deny[msg] {
  net := input.networks["openclaw-net"]
  not net.internal
  msg := "Network openclaw-net must set internal: true (no direct egress routing)."
}

deny[msg] {
  # App must be attached ONLY to openclaw-net
  some n
  svc.networks[n] == "internet-net"
  msg := sprintf("%s must NOT attach to internet-net.", [svc_name])
}

deny[msg] {
  # If networks is list form, it must contain openclaw-net
  not contains_network(svc, "openclaw-net")
  msg := sprintf("%s must attach to openclaw-net.", [svc_name])
}

########################################
# Invariants: no host exposure
########################################

deny[msg] {
  svc.ports
  msg := sprintf("%s must not publish ports.", [svc_name])
}

deny[msg] {
  svc.extra_hosts
  msg := sprintf("%s must not set extra_hosts.", [svc_name])
}

########################################
# Invariants: privilege / capabilities
########################################

deny[msg] {
  svc.privileged == true
  msg := sprintf("%s must not run privileged.", [svc_name])
}

deny[msg] {
  # Must drop all caps
  not svc.cap_drop
  msg := sprintf("%s must set cap_drop: [ALL].", [svc_name])
}

deny[msg] {
  not array_contains(svc.cap_drop, "ALL")
  msg := sprintf("%s must include cap_drop: ALL.", [svc_name])
}

deny[msg] {
  # cap_add can be empty or only NET_ADMIN
  svc.cap_add
  some cap
  svc.cap_add[cap] != "NET_ADMIN"
  msg := sprintf("%s cap_add contains %v; only NET_ADMIN is allowed.", [svc_name, svc.cap_add[cap]])
}

deny[msg] {
  # no-new-privileges should be enabled
  not svc.security_opt
  msg := sprintf("%s must set security_opt: [no-new-privileges:true].", [svc_name])
}

deny[msg] {
  not array_contains(svc.security_opt, "no-new-privileges:true")
  msg := sprintf("%s must include security_opt: no-new-privileges:true.", [svc_name])
}

########################################
# Invariants: filesystem hardening
########################################

deny[msg] {
  svc.read_only != true
  msg := sprintf("%s must set read_only: true.", [svc_name])
}

deny[msg] {
  # tmpfs /tmp required because read_only blocks writing
  not svc.tmpfs
  msg := sprintf("%s must define tmpfs (at least /tmp).", [svc_name])
}

deny[msg] {
  not array_contains_prefix(svc.tmpfs, "/tmp")
  msg := sprintf("%s tmpfs must include /tmp.", [svc_name])
}

########################################
# Invariants: proxy env is set
########################################

deny[msg] {
  not svc.environment
  msg := sprintf("%s must set HTTP_PROXY/HTTPS_PROXY environment.", [svc_name])
}

deny[msg] {
  not env_has_prefix(svc.environment, "HTTP_PROXY=http://squid:3128")
  msg := sprintf("%s must set HTTP_PROXY=http://squid:3128.", [svc_name])
}

deny[msg] {
  not env_has_prefix(svc.environment, "HTTPS_PROXY=http://squid:3128")
  msg := sprintf("%s must set HTTPS_PROXY=http://squid:3128.", [svc_name])
}

########################################
# Helpers
########################################

contains_network(svc, name) {
  # Networks can be list of strings OR a mapping.
  svc.networks[_] == name
} else {
  svc.networks[name]
}

array_contains(arr, val) {
  arr[_] == val
}

array_contains_prefix(arr, prefix) {
  some i
  startswith(arr[i], prefix)
}

env_has_prefix(env, wanted) {
  # env can be list of strings like "K=V"
  env[_] == wanted
} else {
  # or map like { K: V }
  env_key := split(wanted, "=")[0]
  env_val := substring(wanted, count(env_key) + 1, -1)
  env[env_key] == env_val
}
