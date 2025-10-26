#!/usr/bin/env bash

# install unixodbc: 2020 driver/library for ODBC


# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# uncomment these lines if you need to ensure this runs under root/sudo
if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit 1
fi

#set -x

sudo apt update
sudo apt install -y unixodbc
sudo ln -s \
	/usr/lib/x86_64-linux-gnu/libodbc.so.2 \
	/usr/lib/x86_64-linux-gnu/libodbc.so.1

