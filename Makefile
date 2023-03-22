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

.PHONY: firewall
firewall:
	PowerShell 'New-NetFirewallRule -DisplayName "Packer_http_server" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8000-9000'

# Install packer
.PHONY: packer
packer:
	choco install packer --version=1.8.4 -y
	packer init --upgrade ${DISTRO}.pkr.hcl

# Create image for Hyper-V
output-${DISTRO}/${DISTRO}.x86_64.hyperv.box:
	scripts/validate-iso.sh alma8.pkr.hcl 
	packer build --only hyperv-iso.alma8 ${DISTRO}.pkr.hcl
.PHONY: hyperv-image
hyperv-image: output-${DISTRO}/${DISTRO}.x86_64.hyperv.box

# Create image for VirtualBox
output-${DISTRO}/${DISTRO}.x86_64.virtualbox.box:
	scripts/validate-iso.sh alma8.pkr.hcl 
	packer build --only virtualbox-iso.alma8 ${DISTRO}.pkr.hcl
.PHONY: virtualbox-image
virtualbox-image: output-${DISTRO}/${DISTRO}.x86_64.virtualbox.box

# Load hyperv image into Vagrant
.PHONY: hyperv-box
hyperv-box: output-alma8/alma8.x86_64.hyperv.box
	vagrant box add --provider hyperv --name alma8/efi output-${DISTRO}/${DISTRO}.x86_64.hyperv.box

# Load virtualbox image into Vagrant
.PHONY: virtualbox-box
virtualbox-box: output-${DISTRO}/${DISTRO}.x86_64.virtualbox.box
	vagrant box add --provider virtualbox --name alma8/efi output-${DISTRO}/${DISTRO}.x86_64.virtualbox.box

# Start VM with vagrant
vagrant-up:
	vagrant validate
	vagrant box list
	vagrant up --no-provision alma8
	vagrant provision alma8
	vagrant scp alma8:/tmp/report.html .

# Create resource group once for Azure
.PHONY: resource-group
resource-group:
	az group create -l westeurope -n "${ARM_RESOURCE_GROUP}"

# Create storage account once for Azure
.PHONY: storage-account
storage-account:
	az storage account create -l westeurope -g "${ARM_RESOURCE_GROUP}" -n "${ARM_STORAGE_ACCOUNT}" --sku Premium_LRS --https-only true

# Create image for Azure
.PHONY: azure-image
azure-image:
	packer build --only azure-arm.alma8 ${DISTRO}.pkr.hcl

.PHONY: hyperv
hyperv: hyperv-box vagrant-up
	vagrant scp :/tmp/report.html .

.PHONY: virtualbox
virtualbox: clean virtualbox-box vagrant-up
	vagrant scp :/tmp/report.html .
