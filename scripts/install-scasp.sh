#!/usr/bin/env bash

# install scasp as an executable command


# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# # uncomment these lines if you need to ensure this runs under root/sudo
# if [ "$EUID" -ne 0 ]
# 	then echo "Please run as root"
# 	exit 1
# fi


# set -x


[ -d sCASP ] || git clone https://github.com/SWI-Prolog/sCASP.git

cd sCASP

ed Makefile <<-!
	/qlf compile/s::/usr/lib/swi-prolog/boot/qlf.pl compile:
	wq
!

export LD_LIBRARY_PATH=/snap/swi-prolog/current/usr/lib
echo "halt." | make
cp scasp $HOME/installed

cd ..
rm -rf sCASP
