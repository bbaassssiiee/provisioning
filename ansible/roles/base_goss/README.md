[![Galaxy](https://img.shields.io/badge/galaxy-dockpack.base__goss-blue.svg?style=flat)](https://galaxy.ansible.com/dockpack/base_goss)

base_goss
---------

An ansible-role to download the **goss** binary to a dir set by {{ goss_path }}.
The `validate` tag runs health checks by parsing `{{ goss_test_directory }}/test_*.y*ml` files created by other roles.
These are used to validate the server/container against specifications.

[http://goss.rocks](http://goss.rocks)

Requirements
------------

Linux machine. The machine running ansible must have `python-jmespath` installed.

Role Variables
--------------

    goss_version: "v0.3.18"
    goss_path: "/usr/bin/"
    goss_arch: amd64
    goss_dst: /usr/bin/goss
    goss_url: "https://github.com/goss-org/goss/releases/download/{{ goss_version }}/goss-linux-{{ goss_arch }}"
    goss_test_directory: /etc/goss.d
    goss_test_directory_mode: 0755
    goss_user: root
    goss_install_dgoss: true
    goss_download: localhost  # also supports 'direct'

Any new versions of `goss_version` need to be handjammed into `vars/main.yml` because of the manual checksum validation. Currently all known versions are supported.

Dependencies
------------

None

Example Playbook
----------------

    - hosts: servers
      roles:
         - dockpack.base_goss

License
-------

MIT

Author Information
------------------
bbaassssiiee uses Ansible a lot, this role use used to install goss for integration testing.
This role  is based on a role by Sean Abott: https://github.com/sean-abbott/ansible-role-install_goss
