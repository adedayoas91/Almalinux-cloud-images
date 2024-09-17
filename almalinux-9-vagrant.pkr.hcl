# AlmaLinux OS 9 Packer template for Vagrant boxes

source "virtualbox-iso" "almalinux-9" {
  iso_url              = local.iso_url_9_x86_64
  iso_checksum         = "b79079ad71cc3c5ceb3561fff348a1b67ee37f71f4cddfec09480d4589c191d6"
  http_directory       = var.http_directory
  shutdown_command     = var.vagrant_shutdown_command
  ssh_username         = var.vagrant_ssh_username
  ssh_password         = var.vagrant_ssh_password
  ssh_timeout          = var.ssh_timeout
  boot_command         = local.vagrant_boot_command_9_x86_64
  boot_wait            = var.boot_wait
  firmware             = "efi"
  disk_size            = var.vagrant_disk_size
  guest_os_type        = "RedHat_64"
  cpus                 = var.cpus
  memory               = var.memory
  headless             = var.headless
  hard_drive_interface = "sata"
  iso_interface        = "sata"
  vboxmanage           = [["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"]]
  vboxmanage_post = [
    ["modifyvm", "{{.Name}}", "--memory", var.post_memory],
    ["modifyvm", "{{.Name}}", "--cpus", var.post_cpus],
  ]
}

build {
  sources = [
    "source.virtualbox-iso.almalinux-9",
  ]

  provisioner "ansible" {
    galaxy_file          = "./ansible/requirements.yml"
    galaxy_force_install = true
    collections_path     = "./ansible/collections"
    roles_path           = "./ansible/roles"
    playbook_file        = "./ansible/vagrant-box.yml"
    ansible_env_vars = [
      "ANSIBLE_PIPELINING=True",
      "ANSIBLE_REMOTE_TEMP=/tmp",
      "ANSIBLE_SCP_EXTRA_ARGS=-O",
    ]
    extra_arguments = [
      "--extra-vars",
      "packer_provider=${source.type}",
    ]
    only = [
      "virtualbox-iso.almalinux-9",
    ]
  }

  provisioner "ansible" {
    user                 = "vagrant"
    use_proxy            = false
    galaxy_file          = "./ansible/requirements.yml"
    galaxy_force_install = true
    collections_path     = "./ansible/collections"
    roles_path           = "./ansible/roles"
    playbook_file        = "./ansible/vagrant-box.yml"
    ansible_env_vars = [
      "ANSIBLE_PIPELINING=True",
      "ANSIBLE_REMOTE_TEMP=/tmp",
      "ANSIBLE_SCP_EXTRA_ARGS=-O",
      "ANSIBLE_HOST_KEY_CHECKING=False",
    ]
    extra_arguments = [
      "--extra-vars",
      "packer_provider=${source.type} ansible_ssh_pass=root",
    ]
    only = ["hyperv-iso.almalinux-9"]
  }

  post-processors {

    post-processor "vagrant" {
      compression_level = "9"
      output            = "AlmaLinux-9-Vagrant-{{.Provider}}-${var.os_ver_9}-${formatdate("YYYYMMDD", timestamp())}.x86_64.box"
      only = [
        "virtualbox-iso.almalinux-9",
        "hyperv-iso.almalinux-9",
        "vmware-iso.almalinux-9",
        "parallels-iso.almalinux-9",
      ]
    }

    post-processor "vagrant" {
      compression_level    = "9"
      vagrantfile_template = "tpl/vagrant/vagrantfile-libvirt.rb"
      output               = "AlmaLinux-9-Vagrant-{{.Provider}}-${var.os_ver_9}-${formatdate("YYYYMMDD", timestamp())}.x86_64.box"
      only                 = ["qemu.almalinux-9"]
    }
  }
}
