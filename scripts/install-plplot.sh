#!/usr/bin/env bash

# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# install swi-prolog plplot package


# uncomment these lines if you need to ensure this runs under root/sudo
if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit 1
fi


set -x


echo Install SWI-Prolog plplot

echo installing libplplot-dev ...
apt-get install -y libplplot-dev

echo installing plplot package in swi-prolog ...
swipl -g "pack_install(plplot)" -t halt
