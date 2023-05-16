#!/bin/bash -eux
# Remove kickstart server from AlmaLinux host
# Usage: bash remove.sh


ansible-playbook ansible/ks-server-playbook.yml -i ansible/inventory/local -e desired_state=absent -vv
