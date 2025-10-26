#!/usr/bin/env bash

# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# remove thunderbird email

# uncomment these lines if you need to ensure this runs under root/sudo
if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit 1
fi


set -x

snap remove --purge thunderbird
apt remove -y thunderbird
apt purge -y thunderbird
apt autoremove
rm -rf ~/.thunderbird
apt clean
