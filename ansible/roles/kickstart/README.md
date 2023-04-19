# kickstart
This ansible role creates a kickstart installation for AlmaLinux8



### Role variables

It is assumed that the installation_iso_image is downloaded to the homedir of the ansible user.

```yaml
download_folder: /home/vagrant/
installation_iso_image: "{{ download_folder~installation_iso }}"
```

### Required packages


These packages are used from the mounted ISO:
kickstart_grub_rpm: grub2-efi-x64-2.02-106.el8.x86_64.rpm
kickstart_shim_rpm: shim-x64-15.4-2.el8_1.x86_64.rpm

### Role dependencies

Implementing DHCP PXE is beyond the scope of this role.

These dependencies are soft, combine them in the playbook.

- apache
- tftp-setup

### Examples

```yaml
---

- name: Kickstart server
  hosts: kickstart
  gather_facts: true

  roles:
    - role: apache
    - role: tftp-setup
    - role: kickstart
...
```
