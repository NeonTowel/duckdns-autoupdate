#!/bin/bash

# Get domain and token from parameters or environment variables
DOMAINS=${1:-$DUCKDNS_DOMAINS}
TOKEN=${2:-$DUCKDNS_TOKEN}

if [ -z "$DOMAINS" ] || [ -z "$TOKEN" ]; then
  echo "Domains and token must be provided as arguments or environment variables (DUCKDNS_DOMAINS, DUCKDNS_TOKEN)"
  exit 1
fi

# Fetch current WAN IP
CURRENT_IP=$(curl -s https://api.ipify.org)

# Get the first domain to check against
DOMAIN_TO_CHECK=$(echo $DOMAINS | cut -d',' -f1)

# Get current DNS IP for the domain. Requires 'dnsutils' (Debian/Ubuntu) or 'bind-utils' (CentOS/Fedora)
DNS_IP=$(dig +short $DOMAIN_TO_CHECK A | head -n 1)

# Compare and update if necessary
if [ "$DNS_IP" = "$CURRENT_IP" ]; then
  echo "$(date): IP for $DOMAIN_TO_CHECK ($CURRENT_IP) is already up to date. No update performed."
else
  echo "$(date): IP for $DOMAIN_TO_CHECK is $DNS_IP, current IP is $CURRENT_IP. Updating..."
  # Update DuckDNS
  RESPONSE=$(curl -s "https://www.duckdns.org/update?domains=$DOMAINS&token=$TOKEN&ip=$CURRENT_IP")

  # Log results
  if [ "$RESPONSE" = "OK" ]; then
    echo "$(date): IP updated to $CURRENT_IP"
  else
    echo "$(date): Update failed. Response: $RESPONSE"
  fi
fi 