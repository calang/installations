#!/usr/bin/env bash

# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# install gnuplot


# uncomment these lines if you need to ensure this runs under root/sudo
if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit 1
fi


set -x


echo Install gnuplot

if which gnuplot
then
	echo gnuplot is already installed
	exit 0
fi

apt-get install -y gnuplot
