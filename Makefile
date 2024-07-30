ANSIBLE_DEBUG=1
DISTRO ?= alma8

lint:
	packer validate .
	vagrant validate
	ansible-inventory --graph
	ansible-playbook --syntax-check ansible/vagrant-playbook.yml
	ansible-playbook --syntax-check ansible/packer-playbook.yml
	ansible-lint ansible

prepare:
	ansible-galaxy install -p ansible/roles -f -r ansible/roles/requirements.yml
	ansible-galaxy collection install -r ansible/roles/requirements.yml
	packer init --upgrade .

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
	packer init --upgrade .

# Create image for Hyper-V
output-${DISTRO}/${DISTRO}.x86_64.hyperv.box:
	packer build --only hyperv-iso.alma8 .
.PHONY: hyperv-image
hyperv-image: output-${DISTRO}/${DISTRO}.x86_64.hyperv.box

# Create image for VirtualBox
output-${DISTRO}/${DISTRO}.x86_64.virtualbox.box:
	packer build --only virtualbox-iso.alma8 .
.PHONY: virtualbox-image
virtualbox-image: output-${DISTRO}/${DISTRO}.x86_64.virtualbox.box

output-${DISTRO}/${DISTRO}.x86_64.vmware.box:
	packer build --only vmware-iso.alma8 --on-error=abort .
# Create image for VMWare
.PHONY: vmware-image
vmware-image: output-${DISTRO}/${DISTRO}.x86_64.vmware.box

.PHONY: vmware-box
vmware-box:
	vagrant box add --provider vmware_desktop --name ansiblebook/alma8 output-${DISTRO}/${DISTRO}.x86_64.vmware.box
# Load hyperv image into Vagrant
.PHONY: hyperv-box
hyperv-box: output-alma8/alma8.x86_64.hyperv.box
	vagrant box add --provider hyperv --name ansiblebook/alma8 output-${DISTRO}/${DISTRO}.x86_64.hyperv.box

# Load virtualbox image into Vagrant
.PHONY: virtualbox-box
virtualbox-box: output-${DISTRO}/${DISTRO}.x86_64.virtualbox.box
	vagrant box add --provider virtualbox --name ansiblebook/alma8 output-${DISTRO}/${DISTRO}.x86_64.virtualbox.box

# Start VM with vagrant
vagrant-up:
	vagrant validate
	vagrant box list
	vagrant up --no-provision proxy
	vagrant provision proxy

# Create resource group once for Azure
.PHONY: resource-group
resource-group:
	az group create -l westeurope -n "${ARM_RESOURCE_GROUP}"

# Create storage account once for Azure
.PHONY: storage-account
storage-account:
	az storage account create -l westeurope -g "${ARM_RESOURCE_GROUP}" -n "${ARM_STORAGE_ACCOUNT}" --sku Premium_LRS --https-only true

# Create image for Azure
.PHONY: azure-vm
azure-vm:
	az vm create --name alma8 --location westeurope --image /subscriptions/e754b34e-e957-489b-9698-0b07172e0f89/resourceGroups/VMImageResourceGroup/providers/Microsoft.Compute/images/almalinux8 --admin-username "${USER}" --plan-name 8-gen2 --plan-product almalinux --plan-publisher almalinux -g "${ARM_RESOURCE_GROUP}" --ssh-key-values "${HOME}/.ssh/id_rsa.pub" --size Standard_B2ms --nsg alma-nsg --public-ip-sku Standard

# Create image for Azure
.PHONY: azure-image
azure-image:
	packer build --only azure-arm.alma8 .

.PHONY: hyperv
hyperv: hyperv-box vagrant-up
	vagrant scp :/tmp/report.html .

.PHONY: virtualbox
virtualbox: clean virtualbox-box vagrant-up
	vagrant scp :/tmp/report.html .
