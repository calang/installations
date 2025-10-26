#!/usr/bin/env bash

# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# run all installation scripts


# # uncomment these lines if you need to ensure this runs under root/sudo
# if [ "$EUID" -ne 0 ]
# 	then echo "Please run as root"
# 	exit 1
# fi


# set -x
echo 

# get list of all make targets of interest: those composed of lowercase letters, only

LIST=$( \
	grep -E '^[a-z_-]*:' [Mm]akefile \
	| grep -vE 'help:|run-all' \
 	| cut -d : -f 1 \
)
# echo $LIST

for target in $LIST; do
	echo 
	echo "--- $target:"
	make $target
done
