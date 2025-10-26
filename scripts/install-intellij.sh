#!/usr/bin/env bash

# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# install intellij idea


# uncomment these lines if you need to ensure this runs under root/sudo
if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit 1
fi


set -x


echo Remove any previous installation
rm -rf /opt/idea*


echo Download tarball
TAR=ideaIC-2025.2.3.tar.gz

[[ -f $TAR ]] || wget https://download.jetbrains.com/idea/$TAR


echo extract the tarball to /opt
tar -xzf ideaIC-*.tar.gz -C /opt

ln -s /opt/idea-IC* /opt/idea


# create desktop entry
echo '---'
echo To finish up:
echo 
echo 1. Start the app: /opt/idea/bin/idea
echo 2. Click on the settings icon
echo 3. Choose "Create Desktop Entry"
echo '---'

rm $TAR
