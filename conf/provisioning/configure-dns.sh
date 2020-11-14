#!/bin/bash

set -u
set -e
set -v

sed -i -r "s/dns=dnsmasq/dns=none/" /etc/NetworkManager/NetworkManager.conf
pkill dnsmasq || true
rm -rf /var/run/resolvconf/interface/NetworkManager

systemctl restart NetworkManager
systemctl restart networking
