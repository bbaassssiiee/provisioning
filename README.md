# Provisioning

We create an image with Hashicorp Packer and then use it to create VMs with Vagrant.

`make all`

You need to download the ISO and put it in /Users/Shared/. Then update the packer template.

## Packer will create a virtual machine image.

`make image`

## Vagrant will create a VM from the image.

`make virtualbox`

# Requirements

### macOS computer

These programs should be installed.
### Apps
- Packer
- VirtualBox
- Vagrant

### Ansible
run `source install.rc` in a terminal to create a Python virtualenv.
