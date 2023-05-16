#!/bin/bash
# Download collections before going on-premises
# You cannot use curl for some strange reason
# https://galaxy.ansible.com/ansible/posix
# https://galaxy.ansible.com/community/general
ansible-galaxy collection download -p ansible/collections -r ansible/roles/requirements.yml
