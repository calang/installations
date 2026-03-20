#!/usr/bin/env bash

# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# install chrome


# uncomment these lines if you need to ensure this runs under root/sudo
if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit 1
fi

set -x


[[ -f google-chrome-stable_current_amd64.deb ]] || wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

dpkg -i google-chrome-stable_current_amd64.deb && rm google-chrome-stable_current_amd64.deb

set +x
echo If you encounter any dependency issues, resolve them by running:
echo sudo apt-get install -f
