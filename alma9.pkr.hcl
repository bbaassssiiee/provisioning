packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
    hyperv = {
      source = "github.com/hashicorp/hyperv"
      version = "~> 1"
    }
    vmware = {
      version = "~> 1"
      source = "github.com/hashicorp/vmware"
    }
  }
}

source "azure-arm" "alma9" {
  azure_tags = {
    product = "${var.image}"
  }
  plan_info {
    plan_name      = "9-gen2"
    plan_product   = "almalinux"
    plan_publisher = "almalinux"
  }
  image_offer                       = "almalinux"
  image_publisher                   = "almalinux"
  image_sku                         = "9-gen2"
  location                          = "${var.location}"
  managed_image_name                = "${var.image}"
  managed_image_resource_group_name = "${var.managed_image_resource_group_name}"
  os_disk_size_gb                   = "30"
  os_type                           = "Linux"
  client_id                         = "${var.client_id}"
  client_secret                     = "${var.client_secret}"
  tenant_id                         = "${var.tenant_id}"
  subscription_id                   = "${var.subscription_id}"
  use_azure_cli_auth                = false
  vm_size                           = "Standard_DS2_v2"
}

# https://developer.hashicorp.com/packer/plugins/builders/hyperv/iso
source "hyperv-iso" "alma9" {
  boot_command = [
    "c<wait>",
    "linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=AlmaLinux-9-x86_64-dvd ro ",
    "inst.text biosdevname=0 net.ifnames=0 ",
    "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter>",
    "initrdefi /images/pxeboot/initrd.img<enter>",
    "boot<enter><wait>"
  ]
  boot_wait            = "5s"
  communicator         = "ssh"
  cpus                 = 2
  disk_size            = 65536
  disk_block_size      = 1
  enable_secure_boot   = true
  enable_mac_spoofing  = true
  secure_boot_template = "MicrosoftUEFICertificateAuthority"
  generation           = 2
  guest_additions_mode = "disable"
  headless             = true
  http_directory       = "kickstart"
  keep_registered      = false
  iso_checksum         = "${var.iso_checksum}"
  iso_urls             = ["${var.iso_url1}", "${var.iso_url2}"]
  mac_address          = "00c0dedec0de"
  memory               = 2048
  shutdown_command     = "sudo -S shutdown -P now"
  shutdown_timeout     = "30m"
  ssh_password         = "vagrant"
  ssh_username         = "root"
  ssh_wait_timeout     = "10000s"
  switch_name          = "Wi-Fi"
  vm_name              = "alma9-vm"
  vlan_id              = ""
}

source "virtualbox-iso" "alma9" {
  boot_command = [
    "c<wait>",
    "linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=AlmaLinux-9-3-x86_64-dvd ro ",
    "inst.text biosdevname=0 net.ifnames=0 ",
    "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter>",
    "initrdefi /images/pxeboot/initrd.img<enter>",
    "boot<enter><wait>"
  ]
  boot_wait                = "5s"
  cpus                     = 2
  disk_size                = 65536
  firmware                 = "efi"
  gfx_controller           = "vmsvga"
  gfx_efi_resolution       = "1920x1080"
  gfx_vram_size            = "128"
  guest_os_type            = "RedHat_64"
  guest_additions_mode     = "disable"
  hard_drive_interface     = "sata"
  hard_drive_nonrotational = true
  headless                 = false
  http_directory           = "kickstart"
  iso_checksum             = "${var.iso_checksum}"
  iso_interface            = "sata"
  iso_urls                 = ["${var.iso_url1}", "${var.iso_url2}"]
  keep_registered          = false
  memory                   = 4096
  nested_virt              = true
  rtc_time_base            = "UTC"
  shutdown_command         = "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  ssh_password             = "vagrant"
  ssh_username             = "root"
  ssh_wait_timeout         = "10000s"
  usb                      = true
  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--firmware", "EFI"],
    ["modifyvm", "{{.Name}}", "--macaddress1", "auto"],
    ["modifyvm", "{{.Name}}", "--macaddress2", "00c0dedec0de"],
    ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],
    ["modifyvm", "{{.Name}}", "--usbehci", "on"],
  ]
  virtualbox_version_file = ".vbox_version"
  vrdp_bind_address       = "0.0.0.0"
  vrdp_port_min           = "5900"
  vrdp_port_max           = "5900"
  vm_name                 = "alma9-vm"
}

source "vmware-iso" "alma9" {
  boot_command = [
    "<tab>",
    "inst.text net.ifnames=0 inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg",
    "<enter><wait>"
  ]
  boot_wait               = "5s"
  cpus                    = 2
  disk_size               = 65536
  guest_os_type           = "Linux"
  headless                = false
  http_directory          = "kickstart"
  iso_checksum            = "${var.iso_checksum}"
  iso_urls                = ["${var.iso_url1}", "${var.iso_url2}"]
  memory                  = 4096
  ssh_username            = "root"
  ssh_password            = "vagrant"
  ssh_wait_timeout        = "10000s"
  shutdown_command        = "shutdown -P now"
}

build {
  sources = ["source.virtualbox-iso.alma9", "source.hyperv-iso.alma9", "source.vmware-iso.alma9", "source.azure-arm.alma9"]

  provisioner "shell" {
    only            = ["hyperv-iso.alma9", "virtualbox-iso.alma9","vmware-iso.alma9"]
    execute_command = "bash '{{ .Path }}'"
    script          = "scripts/vagrant.sh"
  }
  provisioner "shell" {
    only            = ["hyperv-iso.alma9", "virtualbox-iso.alma9","vmware-iso.alma9"]
    environment_vars = [
      "PROXY=${var.proxy_proto}://${var.proxy_user}:${var.proxy_password}@${var.proxy_host}:${var.proxy_port}"
    ]
    execute_command = "{{ .Vars }} bash '{{ .Path }}'"
    script = "scripts/ansible.sh"
  }
  provisioner "ansible-local" {
    extra_arguments = [ "-vv",
      "-e", "ansible_python_interpreter=/usr/libexec/platform-python",
      "-e", "proxy_proto=${var.proxy_proto}",
      "-e", "proxy_host=${var.proxy_host}",
      "-e", "proxy_port=${var.proxy_port}",
      "-e", "proxy_user=${var.proxy_user}",
      "-e", "proxy_password=${var.proxy_password}", ]
    galaxy_file     = "./ansible/roles/requirements.yml"
    galaxy_command  = "${var.https_proxy} ansible-galaxy"
    playbook_dir    = "./ansible"
    playbook_file   = "./ansible/packer-playbook.yml"
  }
  provisioner "shell" {
    only            = ["azure-arm.alma9"]
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline = [
      "/usr/sbin/waagent -force -deprovision+user",
      "sync"
    ]
    inline_shebang = "/bin/sh -x"
  }

  post-processors {
    post-processor "vagrant" {
      except               = ["azure-arm.alma9"]
      keep_input_artifact  = true
      compression_level    = 9
      output               = "output-alma9/alma9.x86_64.{{.Provider}}.box"
      vagrantfile_template = "Vagrantfile.template"
    }
  }
}
