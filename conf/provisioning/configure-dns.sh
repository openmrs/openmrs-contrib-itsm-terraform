#!/bin/bash

set -u
set -e
set -v

sed -i -r "s/dns=dnsmasq/dns=none/" /etc/NetworkManager/NetworkManager.conf
pkill dnsmasq || true

systemctl restart NetworkManager
systemctl restart networking
