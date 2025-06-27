#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

echo "Uninstalling DuckDNS autoupdate service..."

# Stop and disable the timer
systemctl disable --now duckdns-autoupdate.timer

# Remove files
rm -f /etc/systemd/system/duckdns-autoupdate.service
rm -f /etc/systemd/system/duckdns-autoupdate.timer
rm -f /usr/local/bin/update-duckdns.sh
# rm -f /etc/default/duckdns-autoupdate # Uncomment to also remove config file

echo "Reloading systemd daemon..."
systemctl daemon-reload

echo "Uninstallation complete."
echo "If you want to remove the configuration file, run: rm /etc/default/duckdns-autoupdate" 