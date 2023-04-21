base_line
=========

This amends ansible-lockdown/RHEL8-CIS

Requirements
------------

RHEL8 or derivative. Root privileges with sudo.

Role Variables
--------------

Dependencies
------------

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

```yaml
#!/usr/bin/env ansible-playbook
---

- name: Hardening
  hosts: all
  become: true
  gather_facts: true

  vars:
    rhel8cis_rule_5_3_4: false

  roles:
    - RHEL8-CIS
    - base_line
```
