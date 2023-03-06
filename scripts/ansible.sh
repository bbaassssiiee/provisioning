#!/bin/bash -eux

# If Centos
if [ -e /etc/redhat-release ]; then
    major=$(cat /etc/redhat-release | tr -dc '0-9.'|cut -d \. -f1)
    if (($major < 8))
    then
      # Install EPEL repository.
      sudo yum -y --enablerepo=extras install epel-release
      sudo yum install -y python-pip python-devel python-setuptools git
      sudo yum -y install python-jmespath || pip install jmespath
      # Install Ansible.
      sudo yum -y install ansible ansible-doc ansible-lint
    else
      sudo dnf makecache
      # Install python 3.6 
      sudo dnf install -y git python3 python3-pip python3-jmespath libsemanage-python3 python3-cryptography policycoreutils-python3
      sudo alternatives --set python /usr/bin/python3
      # Install Ansible
      python -m pip install -q ansible
    fi
fi
