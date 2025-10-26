#!/usr/bin/env bash

# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# install VS Code


# uncomment these lines if you need to ensure this runs under root/sudo
if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit 1
fi


set -x


# install the apt repository and signing key

echo "code code/add-microsoft-repo boolean true" | debconf-set-selections

apt-get install -y wget gpg

[[ -f packages.microsoft.gpg ]] \
|| wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg

install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg

echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list > /dev/null

rm -f packages.microsoft.gpg


# update the package cache and install the package

apt install apt-transport-https
apt update
apt install code # or code-insiders

echo '
-----
Recommended extensions:
- New-VSC-Prolog
-----'