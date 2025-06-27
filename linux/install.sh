#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

echo "Installing DuckDNS autoupdate service..."

# Copy files
install -m 755 update-duckdns.sh /usr/local/bin/update-duckdns.sh
install -m 644 duckdns-autoupdate.service /etc/systemd/system/duckdns-autoupdate.service
install -m 644 duckdns-autoupdate.timer /etc/systemd/system/duckdns-autoupdate.timer

# Create environment file
if [ ! -f /etc/default/duckdns-autoupdate ]; then
  echo "Creating environment file at /etc/default/duckdns-autoupdate"
  echo "# DuckDNS configuration" > /etc/default/duckdns-autoupdate
  echo "DUCKDNS_DOMAINS=your_domain" >> /etc/default/duckdns-autoupdate
  echo "DUCKDNS_TOKEN=your_token" >> /etc/default/duckdns-autoupdate
  echo "Please edit /etc/default/duckdns-autoupdate with your domain and token."
else
  echo "Environment file already exists at /etc/default/duckdns-autoupdate, skipping creation."
fi

# Enable and start the timer
echo "Reloading systemd daemon, enabling and starting timer..."
systemctl daemon-reload
systemctl enable --now duckdns-autoupdate.timer

echo "Installation complete."
echo "Check the status of the timer with: systemctl status duckdns-autoupdate.timer"
echo "Check the logs of the service with: journalctl -u duckdns-autoupdate.service" 