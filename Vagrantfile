# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end
  config.vm.provider "virtualbox"
  config.vm.box = "alma8/efi"
  #config.vm.box_download_insecure = true
  config.vm.box_check_update = false
  config.ssh.insert_key = false
  config.ssh.verify_host_key = false
  N = 1
  (1..N).each do |server_id|
    config.vm.define "alma#{server_id}" do |server|
      server.vm.hostname = "alma#{server_id}"
      server.vm.network "private_network", type: "dhcp", bridge: "Default Switch"
      server.vm.synced_folder "/Users/Shared", "/vagrant", id: "vagrant-root", disabled: true
      server.vm.provider "hyperv" do |hyperv|
        hyperv.cpus = 4
        hyperv.memory = "4096"
        hyperv.vmname = "alma#{server_id}"
        hyperv.enable_virtualization_extensions = true
        hyperv.vm_integration_services = {
          guest_service_interface: true,
          heartbeat: true,
          shutdown: true,
          time_synchronization: true,
        }
        hyperv.linked_clone = true
      end
      server.vm.provider "virtualbox" do |virtualbox|
        virtualbox.name = "alma#{server_id}"
        virtualbox.gui = false
        # Boot order setting is ignored if EFI is enabled
        # https://www.virtualbox.org/ticket/19364
        virtualbox.customize ["modifyvm", :id,
          "--audio", "none",
          "--boot1", "disk",
          "--boot2", "net",
          "--boot3", "none",
          "--boot4", "none",
          "--cpus", 4,
          "--firmware", "EFI",
          "--memory", 4096,
          "--usb", "on",
          "--usbehci", "on",
          "--vrde", "on",
          "--graphicscontroller", "VMSVGA",
          "--vram", "64"
        ]
        virtualbox.customize ["storageattach", :id,
          "--device", "0",
          "--medium", "emptydrive",
          "--port", "1",
          "--storagectl", "IDE Controller",
          "--type", "dvddrive"
        ]
      end
          # Only execute once the Ansible provisioner,
      # when all the servers are up and ready
      if server_id == N
        server.vm.provision "file", source: "scripts/ansible.sh", destination: "/home/vagrant/ansible.sh"
        server.vm.provision "shell", upload_path: "/home/vagrant/vagrant-inline", inline: "/bin/sh /home/vagrant/ansible.sh"
        server.vm.provision "file", source: "./ansible", destination: "/home/vagrant/ansible"
        server.vm.provision :ansible_local do |ansible|
          ansible.compatibility_mode = "2.0"
          ansible.extra_vars = { ansible_python_interpreter: "/usr/bin/python3" }
          ansible.galaxy_role_file = "roles/requirements.yml"
          ansible.galaxy_roles_path = "roles"
          ansible.galaxy_command = "ansible-galaxy collection install -r %{role_file} --force && ansible-galaxy role install -p %{roles_path} -r %{role_file} --force"
          ansible.inventory_path = "inventory"
          # Disable default limit to connect to all the servers
          ansible.limit = "alma1"
          ansible.playbook = "/home/vagrant/ansible/vagrant-playbook.yml"
          ansible.provisioning_path = "/home/vagrant/ansible"
          ansible.inventory_path = "/home/vagrant/ansible/inventory/local"
          ansible.galaxy_roles_path = "/home/vagrant/ansible/roles"
          ansible.verbose = ""
        end
      end
    end
  end
end
