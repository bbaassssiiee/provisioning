# Provisioning

This repo can create a VM image with HashiCorp Packer, provision VMs with Vagrant, and deploy Software on it using Ansible.

The VM can run locally on your laptop with a hypervisor like HyperV on Windows or Virtualbox.
The VM will run AlmaLinux/8.
Ansible will be installed in the VM, and the playbooks in the ansible directory are used.

# Requirements

These programs should be installed.

### HyperV on Windows

1. Open a PowerShell console as Administrator.
2. Run the following command:

```PowerShell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```



### VirtualBox

Alternatively you can install VirtualBox and its extension pack from [virtualbox.org](https://www.virtualbox.org/wiki/Downloads)

### Vagrant

Install Vagrant from a [download from HashiCorp](https://developer.hashicorp.com/vagrant/downloads), or with:

**Windows**
```PowerShell
choco install vagrant
```

**macOS**
```sh
brew install hashicorp/tap/hashicorp-vagrant
```

**Linux**
```sh
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install vagrant
```

**Vagrant launches a VM from the image** with `vagrant up`, that will download the [almalinux/8 box](https://app.vagrantup.com/almalinux/boxes/8) for your hypervisor (hyperv/virtualbox/vmware_desktop/libvirt). Unless you created the image yourself with Packer.

### Packer

Alternatively you could customize almalinux/8 yourself (with Hashicorp Packer) to use it for VMs.

Install Packer from a [download from HashiCorp](https://developer.hashicorp.com/packer/downloads), or with:

```PowerShell
	choco install packer --version=1.8.4 -y 
	packer init --upgrade alma8.pkr.hcl
```

#### Network switch in bridge mode

To properly construct a virtual switch in Hyper-V for working with Packer, follow these steps:

1. Open the Hyper-V Manager console and click on the Virtual Switch Manager option in the Actions pane.
1. Select the External option, and then click on Create Virtual Switch.
1. Name your virtual switch 'Bridge' and select the physical network adapter that will be used for the external network.

Click on OK to create the virtual switch.

`make virtualbox`
`make hyperv`

 Packer will download the ISO and put it in the `packer_cache` directory. Partial downloads are appended.

### Ansible

The Vagrant provisioner will install Ansible in the VM, if you need Ansible locally
run `source install.rc` in a terminal to create a Python virtualenv on Linux, macOs or WSL.
