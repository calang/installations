#!/usr/bin/env bash

# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# create alias definitions for bash start-up


# # uncomment these lines if you need to ensure this runs under root/sudo
# if [ "$EUID" -ne 0 ]
# 	then echo "Please run as root"
# 	exit 1
# fi

set -x


echo "
# bash_aliases
#
# file created and overwritten by ~/installations/scripts/alias.sh

alias jupl='jupyter lab'

" >~/.bash_aliases
