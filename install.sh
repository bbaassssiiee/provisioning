#!/bin/bash -ex
# Install kickstart server on air-gapped AlmaLinux host
# requires AlmaLinux-8-latest-x86_64-dvd.iso in parent directory
# Usage: bash install.sh <main_user> <main_password>

# The main user will be allowed ssh access
MAIN_USER=$1
# Password should be 14 chars or more (CIS)
MAIN_PASSWORD=$2

INSTALL_DIR=/var/www/html/install
sudo mkdir -p "$INSTALL_DIR"
if [[ ! -f "$INSTALL_DIR/media.repo" ]]
then
    sudo mount -o loop ../AlmaLinux-8-latest-x86_64-dvd.iso "$INSTALL_DIR"
fi
sudo rm -f /etc/yum.repos.d/*
sudo cp kickstart/almalinux.repo /etc/yum.repos.d/almalinux.repo

# When this is a RHEL8 variant
if [ -e /etc/redhat-release ]; then
   major=$(tr -dc '0-9.' <  /etc/redhat-release | cut -d \. -f1)
   if ((major == 8))
   then
      sudo dnf makecache
      # Installs python 3.9
      sudo dnf install -y git-core ansible-core
    fi
fi

# Air-gapped install of 2 collections
ansible-galaxy collection install --force ansible/collections/ansible-posix-1.5.2.tar.gz
ansible-galaxy collection install --force ansible/collections/community-general-6.6.0.tar.gz

# install a kickstart server
ansible-playbook ansible/ks-server-playbook.yml -i ansible/inventory/local -e main_user="$MAIN_USER" -e main_password="$MAIN_PASSWORD" -vv

