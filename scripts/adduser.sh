#!/usr/bin/env bash

# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# add earth user, if not already created


# uncomment these lines if you need to ensure this runs under root/sudo
if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit 1
fi

set -x


if grep earth /etc/passwd
then
	echo "user earth already exists"
	exit 0
fi

# create user
adduser earth

# add user to sudo group
adduser earth sudo

