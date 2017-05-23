#!/bin/bash

set -u
set -e
set -v

ansible_repo="$1"
ansible_inventory="$2"
hostname="$3"

echo "Repo: ${ansible_repo}, Inv: ${ansible_inventory}, Host: ${hostname}"

fgrep -q "github.com" ~/.ssh/known_hosts || ssh-keyscan github.com >> ~/.ssh/known_hosts
rm -rf /tmp/ansible
git clone -q ${ansible_repo} /tmp/ansible
cd /tmp/ansible/ansible
git crypt unlock
pip install -q "ansible==2.2.3"
ansible-galaxy install -p roles -r requirements.yml --force
ansible-playbook -i inventories/${ansible_inventory} --limit ${hostname}.openmrs.org -c local site.yml
