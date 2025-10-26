#!/usr/bin/env bash

# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# install Sublime Text Editor

# uncomment these lines if you need to ensure this runs under root/sudo
if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit 1
fi


# re: https://www.perplexity.ai/search/how-may-i-install-sublime-in-u-vqVAE3elSPa7eV0vB_7rYQ

set -x

# Update package list
sudo apt update

# Install dependencies
sudo apt install -y apt-transport-https

# Add Sublime Text GPG key
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -

# Add Sublime Text repository
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

# Update package list again
sudo apt update

# Install Sublime Text
sudo apt install -y sublime-text

# Verify installation
if command -v subl &> /dev/null
then
    set x
    echo "Sublime Text has been successfully installed."
    echo "You can now launch it by typing 'subl' in the terminal or finding it in your applications menu."
else
    set x
    echo "Installation failed. Please check for errors and try again."
    exit 1
fi

