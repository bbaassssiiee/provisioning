packer {
  required_plugins {
    hyperv = {
      version = "= 1.0.4"
      source  = "github.com/hashicorp/hyperv"
    }
  }
}

variable "iso_url1" {
  type    = string
  default = "./packer_cache/AlmaLinux-8.7-x86_64-dvd.iso"
}

variable "iso_url2" {
  type    = string
  default = "https://almalinux.mirror.wearetriple.com/8/isos/x86_64/AlmaLinux-8.7-x86_64-dvd.iso"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:b95ddf9d56a849cc8eb4b95dd2321c13af637d3379b91f5d96c39e96fb4403b3"
}

variable "arm_subscription_id" {
  type        = string
  default     = "${env("ARM_SUBSCRIPTION_ID")}"
  description = "https://www.packer.io/docs/builders/azure/arm"
}

variable "arm_location" {
  type        = string
  default     = "westeurope"
  description = "https://azure.microsoft.com/en-us/global-infrastructure/geographies/"
}

variable "arm_resource_group" {
  type        = string
  default     = "${env("ARM_RESOURCE_GROUP")}"
  description = "make arm-resourcegroup in Makefile"
}

variable "arm_storage_account" {
  type        = string
  default     = "${env("ARM_STORAGE_ACCOUNT")}"
  description = "make arm-storageaccount in Makefile"
}

variable "image" {
  type        = string
  default     = "almalinux8"
  description = "Name of the image when created"
}

source "azure-arm" "alma8" {
  azure_tags = {
    product = "${var.image}"
  }
  plan_info  {
    plan_name      = "8-gen2"
    plan_product   = "almalinux"
    plan_publisher = "almalinux"
  }
  image_offer                       = "almalinux"
  image_publisher                   = "almalinux"
  image_sku                         = "8-gen2"
  location                          = "${var.arm_location}"
  managed_image_name                = "${var.image}"
  managed_image_resource_group_name = "${var.arm_resource_group}"
  os_disk_size_gb                   = "30"
  os_type                           = "Linux"
  subscription_id                   = "${var.arm_subscription_id}"
  use_azure_cli_auth                = true
  vm_size                           = "Standard_DS2_v2"
}

# https://developer.hashicorp.com/packer/plugins/builders/hyperv/iso
source "hyperv-iso" "alma8" {
  boot_command   = [
    "c<wait>",
    "linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=AlmaLinux-8-7-x86_64-dvd ro ",
    "inst.text biosdevname=0 net.ifnames=0 ",
    "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter>",
    "initrdefi /images/pxeboot/initrd.img<enter>",
    "boot<enter><wait>"
  ]
  boot_wait              = "5s"
  communicator           = "ssh"
  cpus                   = 2
  disk_size              = 65536
  disk_block_size        = 1
  enable_secure_boot     = true
  enable_mac_spoofing    = true
  secure_boot_template   = "MicrosoftUEFICertificateAuthority"
  generation             = 2
  headless               = true
  http_directory         = "kickstart"
  keep_registered        = true
  iso_checksum           = "${var.iso_checksum}"
  iso_urls               = ["${var.iso_url1}", "${var.iso_url2}"]
  memory                 = 2048
  shutdown_command       = "echo 'vagrant' | sudo -S shutdown -P now"
  shutdown_timeout       = "30m"
  ssh_password           = "vagrant"
  ssh_username           = "vagrant"
  ssh_wait_timeout       = "10000s"
  switch_name            = "Bridge"
  vm_name                = "alma8-vm"
  vlan_id                = ""
}

source "virtualbox-iso" "alma8" {
  boot_command   = [
    "c<wait>",
    "linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=AlmaLinux-8-7-x86_64-dvd ro ",
    "inst.text biosdevname=0 net.ifnames=0 ",
    "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter>",
    "initrdefi /images/pxeboot/initrd.img<enter>",
    "boot<enter><wait>"
]
  boot_wait              = "5s"
  cpus                   = 2
  disk_size              = 65536
  firmware               = "efi"
  gfx_controller         = "vmsvga"
  gfx_efi_resolution     = "1920x1080"
  gfx_vram_size          = "128"
  guest_os_type          = "RedHat_64"
  guest_additions_mode   = "disable"
  hard_drive_interface   = "sata"
  hard_drive_nonrotational = true
  headless               = true
  http_directory         = "kickstart"
  iso_checksum           = "${var.iso_checksum}"
  iso_interface          = "ide"
  iso_urls               = ["${var.iso_url1}", "${var.iso_url2}"]
  memory                 = 4096
  nested_virt            = true
  shutdown_command       = "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  ssh_password           = "vagrant"
  ssh_username           = "vagrant"
  ssh_wait_timeout       = "10000s"
  rtc_time_base          = "UTC"
  usb                    = true
  vboxmanage = [
    [ "modifyvm", "{{.Name}}", "--firmware", "EFI" ],
    [ "modifyvm", "{{.Name}}", "--usbehci", "on" ],
  ]
  virtualbox_version_file= ".vbox_version"
  vrdp_bind_address      = "0.0.0.0"
  vrdp_port_min          = "5900"
  vrdp_port_max          = "5900"
  vm_name                = "alma8-vm"
}

build {
  sources = ["source.virtualbox-iso.alma8", "source.hyperv-iso.alma8", "source.azure-arm.alma8"]

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    scripts         = ["scripts/ansible.sh"]
  }
  provisioner "ansible-local" {
    extra_arguments = ["--extra-vars", "ansible_python_interpreter=/usr/bin/python3"]
    galaxy_file = "./ansible/roles/requirements.yml"
    playbook_dir = "./ansible"
    playbook_file = "./ansible/packer-playbook.yml"
  }

  provisioner "shell" {
    only   = ["virtualbox-iso.alma8"]
    execute_command = "{{ .Vars }} /usr/bin/sudo -S -E bash '{{ .Path }}'"
    script          = "scripts/cleanup.sh"
  }

  provisioner "shell" {
    only   = ["azure-arm.alma8"]
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline = [
      "/usr/sbin/waagent -force -deprovision+user",
      "sync"
    ]
    inline_shebang  = "/bin/sh -x"
  }

  post-processors {
    post-processor "vagrant" {
      except   = ["azure-arm.alma8"]
      keep_input_artifact  = true
      compression_level    = 9
      output               = "output-alma8/alma8.x86_64.{{.Provider}}.box"
      vagrantfile_template = "Vagrantfile.template"
    }
  }
}
