#!/usr/bin/env bash

# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# install zoom


# uncomment these lines if you need to ensure this runs under root/sudo
if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit 1
fi


set -x


apt update

[[ -f zoom_amd64.deb ]] \
|| wget https://zoom.us/client/6.2.3.2056/zoom_amd64.deb

apt install -y ./zoom_amd64.deb \
&& rm zoom_amd64.deb

