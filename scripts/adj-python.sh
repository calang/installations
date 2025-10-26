#!/usr/bin/env bash

# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# apply system-wide python adjustments


# uncomment these lines if you need to ensure this runs under root/sudo
if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit 1
fi

# set -x


. scripts/ensure_apt.sh


# set default Python version
# apt-get install -y python-is-python3
ensure_apt python-is-python3

# install python packages
# apt install -y python3-pip
ensure_apt python3-pip
# apt install -y python3.12-venv
ensure_apt python3.12-venv
