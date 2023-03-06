ANSIBLE_DEBUG=1
DISTRO ?= alma8
prepare:
	ansible-inventory --graph
	ansible-galaxy install -p roles -f -r roles/requirements.yml
	ansible-galaxy collection install -r collections/requirements.yml
	ansible-playbook --syntax-check vagrant-playbook.yml
	ansible-lint vagrant-playbook.yml

lint:
	vagrant validate
	packer validate ${DISTRO}.pkr.hcl

clean: lint
	@vagrant destroy -f
	@ssh-keygen -R 192.168.56.11
	@ssh-keygen -R 192.168.56.12
	@ssh-keygen -R 192.168.56.13
	@vagrant box remove ${DISTRO}/efi || /usr/bin/true
	@rm -rf output-${DISTRO} .vagrant

output-${DISTRO}/${DISTRO}.box:
	packer build ${DISTRO}.pkr.hcl

box: output-${DISTRO}/${DISTRO}.box
	vagrant box add --force --name ${DISTRO}/efi output-${DISTRO}/${DISTRO}.box

image: output-${DISTRO}/${DISTRO}.box

all: clean box
	vagrant up
