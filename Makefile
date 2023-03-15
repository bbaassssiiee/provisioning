ANSIBLE_DEBUG=1
DISTRO ?= alma8

lint:
	vagrant validate
	ansible-inventory --graph
	ansible-playbook --syntax-check ansible/vagrant-playbook.yml
	ansible-playbook --syntax-check ansible/packer-playbook.yml
	ansible-lint ansible
	packer validate ${DISTRO}.pkr.hcl

prepare:
	ansible-galaxy install -p ansible/roles -f -r ansible/roles/requirements.yml
	ansible-galaxy collection install -r ansible/roles/requirements.yml
	packer init --upgrade ${DISTRO}.pkr.hcl

clean:
	@vagrant destroy -f
	@vagrant box remove alma8/efi || /usr/bin/true
	@rm -rf output-${DISTRO} .vagrant
	@ssh-keygen -R 192.168.56.31
	@ssh-keygen -R 192.168.56.32
	@ssh-keygen -R 192.168.56.33

.PHONY: firewall
firewall:
	PowerShell 'New-NetFirewallRule -DisplayName "Packer_http_server" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8000-9000'

# Install packer
.PHONY: packer
packer:
	choco install packer --version=1.8.4 -y
	packer init --upgrade ${DISTRO}.pkr.hcl

# Create image for Hyper-V
.PHONY: hyperv-image
hyperv-image:
	packer build --only hyperv-iso.alma8 ${DISTRO}.pkr.hcl
output-${DISTRO}/${DISTRO}.x86_64.hyperv.box:
	packer build --only hyperv-iso.alma8 ${DISTRO}.pkr.hcl

# Create image for VirtualBox
.PHONY: virtualbox-image
virtualbox-image:
	packer build --only virtualbox-iso.alma8 ${DISTRO}.pkr.hcl
output-${DISTRO}/${DISTRO}.x86_64.virtualbox.box:
	packer build --only virtualbox-iso.alma8 ${DISTRO}.pkr.hcl

# Load hyperv image into Vagrant
.PHONY: hyperv-box
hyperv-box: output-${DISTRO}/${DISTRO}.x86_64.hyperv.box
	vagrant box add --provider hyperv --name alma8/efi output-${DISTRO}/${DISTRO}.x86_64.hyperv.box

# Load virtualbox image into Vagrant
.PHONY: virtualbox-box
virtualbox-box: output-${DISTRO}/${DISTRO}.x86_64.virtualbox.box
	vagrant box add --provider virtualbox --name alma8/efi output-${DISTRO}/${DISTRO}.x86_64.virtualbox.box

# Start VM with vagrant
vagrant-up:
	vagrant validate
	vagrant box list
	vagrant up --no-provision
	vagrant provision
	vagrant scp :/tmp/report.html .

# Create image for Azure
.PHONY: azure-image
azure:-image
	packer build --only azure-arm.alma8 ${DISTRO}.pkr.hcl

.PHONY: hyperv
hyperv: clean hyperv-box vagrant-up
	vagrant scp :/tmp/report.html .

.PHONY: virtualbox
virtualbox: clean virtualbox-box vagrant-up
