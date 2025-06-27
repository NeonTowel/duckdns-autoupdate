#!/bin/bash

# Get domain and token from parameters or environment variables
DOMAIN_TO_CHECK=${1:-$DUCKDNS_DOMAIN}
TOKEN=${2:-$DUCKDNS_TOKEN}
DNS_SERVERS=("1.1.1.1" "8.8.8.8" "9.9.9.9" "208.67.222.222" "208.67.220.220" "4.2.2.1") # DNS servers to try for resolution

# Check if the domain is valid
if ! echo "$DOMAIN_TO_CHECK" | grep -qE '^[a-zA-Z0-9.-]+\.duckdns\.org$'; then
  echo "Invalid domain format. Please provide a valid DuckDNS domain (e.g., 'example.duckdns.org')."
  exit 1
fi

# Check if the token is valid
if [ -z "$TOKEN" ]; then
  echo "Token must be provided as an argument or environment variable (DUCKDNS_TOKEN)"
  exit 1
fi

# Fetch current WAN IP
CURRENT_IP=$(curl -s https://api.ipify.org)

# Get current DNS IP for the domain. Requires 'dnsutils' (Debian/Ubuntu) or 'bind-utils' (CentOS/Fedora)
DNS_IP=""
for server in "${DNS_SERVERS[@]}"; do
    echo "$(date): INFO: Resolving $DOMAIN_TO_CHECK using $server..."
    # Resolve and validate the new IP address, ensuring it's a valid IPv4 address
    DNS_IP=$(dig +short "$DOMAIN_TO_CHECK" A @"$server" | head -n 1 | grep -oE '^([0-9]{1,3}\.){3}[0-9]{1,3}$')
    if [ -n "$DNS_IP" ]; then
        break # Successfully resolved
    fi
    echo "$(date): INFO: Failed to resolve $DOMAIN_TO_CHECK using $server. Trying next..."
done

# Compare and update if necessary
if [ "$DNS_IP" = "$CURRENT_IP" ]; then
  echo "$(date): IP for $DOMAIN_TO_CHECK ($CURRENT_IP) is already up to date. No update performed."
else
  echo "$(date): IP for $DOMAIN_TO_CHECK is $DNS_IP, current IP is $CURRENT_IP. Updating..."
  
  # DuckDNS expects only the subdomain part of the domain in the update URL
  SUBDOMAIN=$(echo "$DOMAIN_TO_CHECK" | sed 's/\.duckdns\.org//g')
  
  # Update DuckDNS
  RESPONSE=$(curl -s "https://www.duckdns.org/update?domains=$SUBDOMAIN&token=$TOKEN&ip=")

  # Log results
  if [ "$RESPONSE" = "OK" ]; then
    echo "$(date): IP updated to $CURRENT_IP"
  else
    echo "$(date): Update failed. Response: $RESPONSE"
  fi
fi 