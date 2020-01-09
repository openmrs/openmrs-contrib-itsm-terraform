#!/bin/bash

set -u
set -e
set -v

ansible_repo="$1"
ansible_inventory="$2"
hostname="$3"

echo "Repo: ${ansible_repo}, Inv: ${ansible_inventory}, Host: ${hostname}"

yes | DEBIAN_FRONTEND=noninteractive aptdcon --hide-terminal -i git-crypt python-dev libffi-dev
fgrep -q "github.com" ~/.ssh/known_hosts || ssh-keyscan github.com >> ~/.ssh/known_hosts
rm -rf /tmp/ansible
chmod 600 /root/.ssh/id_rsa

git clone -q ${ansible_repo} /tmp/ansible
cd /tmp/ansible/ansible

# temp branch to upgrade ansible
git checkout ITSM-3933
git crypt unlock

pip install -q "ansible==2.9.2"
ansible-galaxy install -p roles -r requirements.yml --force
ansible-playbook -i inventories/${ansible_inventory} --limit ${hostname}.openmrs.org -c local site.yml || true

rm -rf /tmp/ansible
rm /root/.ssh/id_rsa
rm -rf /root/.gnupg
