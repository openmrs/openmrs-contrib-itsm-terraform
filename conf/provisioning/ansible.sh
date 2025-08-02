#!/bin/bash

set -u
set -e
set -v

ansible_repo="$1"
ansible_inventory="$2"
hostname="$3"

echo "Repo: ${ansible_repo}, Inv: ${ansible_inventory}, Host: ${hostname}"

export DEBIAN_FRONTEND=noninteractive
apt-get -yq install git-crypt libffi-dev python-is-python3 python3-pip build-essential libssl-dev libffi-dev python3-dev python3.11-full python3-virtualenv

## Do not change to 3.11, this will cause errors on apt-get update!
# update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 2
# update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
# update-alternatives --set python3 /usr/bin/python3.10

fgrep -q "github.com" ~/.ssh/known_hosts || ssh-keyscan github.com >> ~/.ssh/known_hosts
rm -rf /tmp/ansible
chmod 600 /root/.ssh/id_rsa

git clone -q ${ansible_repo} /tmp/ansible
cd /tmp/ansible/ansible
git crypt unlock

virtualenv -p /usr/bin/python3.11 myenv # so apt-get update doesn't break
source myenv/bin/activate

pip3 install -q "ansible-core==2.18.6"
pip3 install --upgrade cryptography

ansible-config --version

ansible-galaxy collection download -r requirements.yml
ansible-galaxy install -r requirements.yml --force
ansible-playbook -i inventories/${ansible_inventory} --limit ${hostname}.openmrs.org --tags basic-os,soe,monitoring -c local site.yml || true

deactivate

rm -rf /tmp/ansible
rm /root/.ssh/id_rsa
rm -rf /root/.gnupg
