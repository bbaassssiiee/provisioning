#!/bin/bash -eux
# When this is a RHEL8 variant
if [ -e /etc/redhat-release ]; then
   major=$(tr -dc '0-9.' <  /etc/redhat-release | cut -d \. -f1)
   if ((major == 8))
   then
     sudo dnf makecache
     # ansible-core installs python3.x and git-core
     sudo dnf install -y ansible-core
     # For platform-python for remote use.
     sudo dnf install -y python3-jmespath
     # Upgrade if possible
     sudo dnf upgrade -y ansible-core || /usr/bin/true
     # Install pip
     sudo dnf install -y python3.11-pip
   fi
fi
# /etc/alternatives/pip3 will point to 3.6, ansible uses 3.11
sudo pip3.11 install jmespath
ansible --version
