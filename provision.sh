#!/bin/bash

#######################################
# Set up the development environement
#######################################

WEBSTORM_VERSION=11.0.3

PROVISIONED_ON=/etc/vm_provision_on_timestamp
if [ -f "$PROVISIONED_ON" ]
then
  echo "VM was already provisioned at: $(cat $PROVISIONED_ON)"
  echo "To run system updates manually login via 'vagrant ssh' and run 'apt-get update && apt-get upgrade'"
  echo ""
  exit
fi

#######################################
# Add additional repositories

# see: http://www.ubuntuupdates.org/ppa/sublime_text_3
add-apt-repository ppa:webupd8team/sublime-text-3 

# for installing Chrome
wget -nv -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'

apt-get update

#######################################
# Install tools

# Setup tools
apt-get install -y git
apt-get install -y sublime-text-installer
apt-get install -y default-jdk  #needed for WebStorm
apt-get install -y meld #visual diff/merge tool
apt-get install -y jq #json query command line tool
apt-get install -y vim

# Setup python
apt-get install -y python python-pip

# Add docker
curl -sSL https://get.docker.com/ | sh

# allow using docker as a non-root user
usermod -aG docker vagrant

# Add PEP8, Virtualenv
pip install pep8
pip install virtualenv

# Setup Sublime Package Managers
chown -R vagrant:vagrant /home/vagrant/.config/
SUBLIME_DIR="/home/vagrant/.config/sublime-text-3/"
SUBLIME_PACKAGE_DIR=$SUBLIME_DIR"Packages/"
SUBLIME_INSTALL_PACKAGE_DIR=$SUBLIME_DIR"Installed Packages/"

mkdir -p "$SUBLIME_INSTALL_PACKAGE_DIR"
wget -nv -P "$SUBLIME_INSTALL_PACKAGE_DIR" https://packagecontrol.io/Package%20Control.sublime-package

# Add Sublime packages
mkdir -p "$SUBLIME_PACKAGE_DIR"
git clone https://github.com/SublimeText-Markdown/MarkdownEditing.git "$SUBLIME_PACKAGE_DIR"MarkdownEditing
git clone https://github.com/colinta/SublimeFileDiffs.git "$SUBLIME_PACKAGE_DIR"SublimeFileDiffs
git clone https://github.com/titoBouzout/SideBarEnhancements.git "$SUBLIME_PACKAGE_DIR"SideBarEnhancements
git clone https://github.com/SublimeLinter/SublimeLinter3.git "$SUBLIME_PACKAGE_DIR"SublimeLinter
git clone https://github.com/wbond/sublime_terminal.git "$SUBLIME_PACKAGE_DIR"sublime_terminal
git clone https://github.com/jisaacks/GitGutter.git "$SUBLIME_PACKAGE_DIR"GitGutter
git clone https://github.com/SublimeLinter/SublimeLinter-pep8.git "$SUBLIME_PACKAGE_DIR"SublimeLinter-pep8

chown -R vagrant:vagrant "$SUBLIME_INSTALL_PACKAGE_DIR"
chown -R vagrant:vagrant "$SUBLIME_PACKAGE_DIR"
chown -R vagrant:vagrant "$SUBLIME_DIR"

# Install WebStorm
# Don't download if the package already exists locally on the host
if [ ! -f /vagrant/WebStorm-$WEBSTORM_VERSION.tar.gz ]; then
    echo "WebStorm not found. Downloading..."
    wget -nv -P /vagrant/ http://download.jetbrains.com/webstorm/WebStorm-$WEBSTORM_VERSION.tar.gz

fi

tar -xvf /vagrant/WebStorm-$WEBSTORM_VERSION.tar.gz
chown -R vagrant:vagrant WebStorm-$WEBSTORM_VERSION/

# Install Chrome
apt-get install -y google-chrome-stable

# Setup meld as the default merge and diff tool
su - vagrant -c "git config --global merge.tool meld"
su - vagrant -c "git config --global diff.tool meld"

# Cache git credentials for period of 10 hours
su - vagrant -c "git config --global credential.helper 'cache --timeout=36000'"

# Tag the provision time:
date > "$PROVISIONED_ON"

echo "Successfully created Development VM"