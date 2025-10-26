#!/usr/bin/env bash

# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# install xdot


# uncomment these lines if you need to ensure this runs under root/sudo
if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit 1
fi


set -x


apt install -y gir1.2-gtk-3.0 python3-gi python3-gi-cairo python3-numpy graphviz

apt install -y xdot
