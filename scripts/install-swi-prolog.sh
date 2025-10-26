#!/usr/bin/env bash

# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# install swi-prolog


# uncomment these lines if you need to ensure this runs under root/sudo
if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit 1
fi


set -x


echo Install SWI-Prolog

# if which swipl 
# then
# 	echo swipl is already installed
# 	exit 0
# fi

# apt-get install -y swi-prolog


echo
echo "Please refer to $HOME/proyects/ref_no_bkup/swipl-devel/local directory"
echo "for specific instructions to install the latest development environment"


CFG_FILE=~/.config/swi-prolog/init.pl
echo
echo "This script will simply set $CFG_FILE"


echo Update initialization file $CFG_FILE
echo -e '\n\n:- use_module(library(clpfd)).\n' >>$CFG_FILE
