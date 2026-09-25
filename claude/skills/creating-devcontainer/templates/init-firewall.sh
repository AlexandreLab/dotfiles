#!/bin/bash
# init-firewall.sh – Restrictive outbound firewall for AI agent dev containers
#
# Policy: DEFAULT DENY all outbound traffic except an explicit allowlist.
# Add domains for your stack to ALLOWED_DOMAINS below.
#
# Reference: https://github.com/anthropics/claude-code/blob/main/.devcontainer/init-firewall.sh
set -euo pipefail
IFS=$'\n\t'

echo "=== Initializing firewall ==="

# 1. Capture Docker's internal DNS rules BEFORE flushing anything
DOCKER_DNS_RULES=$(iptables-save -t nat | grep "127\.0\.0\.11" || true)

# 2. Flush all existing rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
ipset destroy allowed-domains 2>/dev/null || true

# 3. Restore Docker's internal DNS resolution
if [ -n "$DOCKER_DNS_RULES" ]; then
    echo "Restoring Docker DNS rules..."
    iptables -t nat -N DOCKER_OUTPUT 2>/dev/null || true
    iptables -t nat -N DOCKER_POSTROUTING 2>/dev/null || true
    echo "$DOCKER_DNS_RULES" | xargs -L 1 iptables -t nat
fi

# 4. Always-allowed traffic
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT   # Outbound DNS
iptables -A INPUT  -p udp --sport 53 -j ACCEPT   # DNS responses
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT   # Outbound SSH
iptables -A INPUT  -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT  -i lo -j ACCEPT               # Localhost
iptables -A OUTPUT -o lo -j ACCEPT

# 5. Allow host network (VS Code remote, devcontainer CLI)
HOST_IP=$(ip route | grep default | cut -d" " -f3)
if [ -z "$HOST_IP" ]; then
    echo "ERROR: Failed to detect host IP"
    exit 1
fi
HOST_NETWORK=$(echo "$HOST_IP" | sed "s/\.[0-9]*$/.0\/24/")
echo "Host network: $HOST_NETWORK"
iptables -A INPUT  -s "$HOST_NETWORK" -j ACCEPT
iptables -A OUTPUT -d "$HOST_NETWORK" -j ACCEPT

# 6. Build allowlist ipset
ipset create allowed-domains hash:net

# GitHub – fetch dynamic IP ranges from the meta API
echo "Fetching GitHub IP ranges..."
gh_ranges=$(curl -s https://api.github.com/meta)
if [ -z "$gh_ranges" ]; then
    echo "ERROR: Failed to fetch GitHub IP ranges"
    exit 1
fi
echo "$gh_ranges" | jq -r '(.web + .api + .git)[]' | aggregate -q | while read -r cidr; do
    echo "  Adding GitHub range $cidr"
    ipset add allowed-domains "$cidr"
done

# Allowed domains: add or remove entries for your stack.
# The list mirrors Anthropic's reference firewall; compare against it when
# updating, since the domains Claude Code needs can change.
ALLOWED_DOMAINS=(
    "registry.npmjs.org"
    "api.anthropic.com"
    # Telemetry and error reporting in the reference firewall (to check upstream):
    "sentry.io"
    "statsig.com"
    # Python packages:
    # "pypi.org"
    # "files.pythonhosted.org"
    # Your project's APIs:
    # "api.yourservice.com"
)
for domain in "${ALLOWED_DOMAINS[@]}"; do
    echo "Resolving $domain..."
    ips=$(dig +noall +answer A "$domain" | awk '$4 == "A" {print $5}')
    if [ -z "$ips" ]; then
        echo "ERROR: Failed to resolve $domain"
        exit 1
    fi
    while read -r ip; do
        echo "  Adding $ip for $domain"
        ipset add -exist allowed-domains "$ip"
    done <<< "$ips"
done

# 7. Apply default-deny policy
iptables -P INPUT   DROP
iptables -P FORWARD DROP
iptables -P OUTPUT  DROP

# Allow already-established connections
iptables -A INPUT  -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow traffic to whitelisted IPs
iptables -A OUTPUT -m set --match-set allowed-domains dst -j ACCEPT

# Reject everything else with immediate feedback (no silent drops)
iptables -A OUTPUT -j REJECT --reject-with icmp-admin-prohibited

# 8. Verify the firewall
echo "Verifying firewall..."
if curl --connect-timeout 5 https://example.com >/dev/null 2>&1; then
    echo "ERROR: Firewall check FAILED – example.com is reachable (should be blocked)"
    exit 1
fi
echo "  PASS: example.com is blocked"

if ! curl --connect-timeout 5 https://api.github.com/zen >/dev/null 2>&1; then
    echo "ERROR: Firewall check FAILED – api.github.com is unreachable (should be allowed)"
    exit 1
fi
echo "  PASS: api.github.com is reachable"

echo "=== Firewall active ==="
