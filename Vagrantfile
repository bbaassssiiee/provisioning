# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  # Install required plugins

  required_plugins = %w( vagrant-scp )
  plugin_installed = false
  required_plugins.each do |plugin|
    unless Vagrant.has_plugin?(plugin)
      system "vagrant plugin install #{plugin}"
      plugin_installed = true
    end
  end

  # If new plugins installed, restart Vagrant process
  if plugin_installed === true
    exec "vagrant #{ARGV.join' '}"
  end

  # Skip compiling guest additions
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end

  config.vm.box = "alma8/efi"
  config.vm.box_check_update = false
  config.ssh.insert_key = false

  cluster = {
    "artifactory" => { :autostart => false, :mac => "00-C0-DE-DE-C0-DE", :cpus => 4, :mem => 4096, :port => 8081},
    "proxy" => { :autostart => false, :mac => "00-15-5D-C0-FF-EE", :cpus => 4, :mem => 4096 , :port => 3128 },
    "alma8" => { :autostart => true, :mac => "00-15-5D-DE-CA-FE", :cpus => 4, :mem => 4096, :port => 5432 }
  }
  cluster.each_with_index do |(hostname, params), index|
    config.vm.define hostname, autostart: params[:autostart] do |server|
      server.vm.hostname = hostname
      #server.vm.network "private_network", type: "dhcp", bridge: "Default Switch"
      server.vm.network "public_network", type: "dhcp", bridge: "Wi-Fi"
      server.vm.network :forwarded_port, host: params[:port], guest: params[:port]
      server.vm.synced_folder "/Users/Shared", "/vagrant", id: "vagrant-root", disabled: true
      server.vm.provider "hyperv" do |hyperv|
        hyperv.cpus = params[:cpus]
        hyperv.memory = params[:mem]
        hyperv.mac = params[:mac]
        hyperv.vmname = hostname
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

        virtualbox.name = hostname
        virtualbox.linked_clone = true
        virtualbox.gui = false
        virtualbox.default_nic_type = "82540em"
        # Boot order setting is ignored if EFI is enabled
        # https://www.virtualbox.org/ticket/19364
        virtualbox.customize ["modifyvm", :id,
          "--audio", "none",
          "--boot1", "disk",
          "--boot2", "net",
          "--boot3", "none",
          "--boot4", "none",
          "--cpus", params[:cpus],
          "--firmware", "EFI",
          "--macaddress2", params[:mac].gsub("-", ""),
          "--memory", params[:mem],
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

      server.vm.provision "file", source: "scripts/ansible.sh", destination: "/home/vagrant/ansible.sh"
      server.vm.provision "shell", upload_path: "/home/vagrant/vagrant-inline", inline: "/bin/sh /home/vagrant/ansible.sh"
      server.vm.provision "file", source: "./ansible", destination: "/home/vagrant/ansible"
      server.vm.provision :ansible_local do |ansible|
        ansible.compatibility_mode = "2.0"
        ansible.extra_vars = { ansible_python_interpreter: "/usr/bin/python3" }
        # Download dependencies
        ansible.galaxy_role_file = "roles/requirements.yml"
        ansible.galaxy_roles_path = "roles"
        ansible.galaxy_command = "ansible-galaxy collection install -r %{role_file} --force && ansible-galaxy role install -p %{roles_path} -r %{role_file} --force"
        ansible.inventory_path = "inventory"
        ansible.playbook = "/home/vagrant/ansible/vagrant-playbook.yml"
        ansible.provisioning_path = "/home/vagrant/ansible"
        ansible.inventory_path = "/home/vagrant/ansible/inventory/local"
        ansible.groups = {
          "almalinux" => ["alma8"],
          "artifactory_servers" => ["artifactory"],
          "postgres_servers" => ["artifactory"],
          "proxy" => ["proxy"]
        }
        ansible.galaxy_roles_path = "/home/vagrant/ansible/roles"
        ansible.verbose = "vv"
      end
    end
  end
end
