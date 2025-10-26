#!/usr/bin/env bash

# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# install yed


# # uncomment these lines if you need to ensure this runs under root/sudo
# if [ "$EUID" -ne 0 ]
# 	then echo "Please run as root"
# 	exit 1
# fi


set -x


# FILE=yEd-3.24_with-JRE22_64-bit_setup.sh
FILE=yEd-3.25.1_with-JRE23_64-bit_setup.sh



[[ -f $FILE ]] || wget https://www.yworks.com/resources/yed/demo/$FILE

chmod +x $FILE

./$FILE && rm -rf $FILE
