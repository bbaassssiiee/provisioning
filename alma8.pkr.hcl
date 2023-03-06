variable "iso_url1" {
  type    = string
  default = "file:///Users/Shared/AlmaLinux-8.7-x86_64-dvd.iso"
}

variable "iso_url2" {
  type    = string
  default = "https://almalinux.mirror.wearetriple.com/8/isos/x86_64/AlmaLinux-8.7-x86_64-dvd.iso"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:b95ddf9d56a849cc8eb4b95dd2321c13af637d3379b91f5d96c39e96fb4403b3"
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
  sources = ["source.virtualbox-iso.alma8"]

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    scripts         = ["scripts/cleanup.sh"]
  }
  provisioner "ansible" {
    playbook_file = "./packer-playbook.yml"
  }
  post-processors {
    post-processor "vagrant" {
      keep_input_artifact  = true
      compression_level    = 9
      output               = "output-alma8/alma8.box"
      vagrantfile_template = "Vagrantfile.template"
    }
  }
}
