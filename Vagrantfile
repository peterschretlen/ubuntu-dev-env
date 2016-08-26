# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box = "box-cutter/ubuntu1404-desktop"
  config.vm.network "forwarded_port", guest: 8000, host: 8080
  config.vm.hostname = "ubuntu-dev-env"

  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = true
    vb.name = "ubuntu-dev-env"
  
    # Customize the amount of memory on the VM:
    vb.memory = "4096"
    vb.cpus = 2
  end

  # Copies your local gitconfig to the VM so you don't have to set it up again
  config.vm.provision "file", source: "~/.gitconfig", destination: ".gitconfig"

  # Installs all packages and tools 
  config.vm.provision :shell, path: "provision.sh"

end
