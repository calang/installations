#!/usr/bin/env bash

# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# adjust bash prompt


# # uncomment these lines if you need to ensure this runs under root/sudo
# if [ "$EUID" -ne 0 ]
# 	then echo "Please run as root"
# 	exit 1
# fi

set -x


# change 34 (blue) for 36 (magenta)
# change \w (pwd) for \W (baseline `pwd`)
# encoding: https://www.perplexity.ai/search/in-my-bashrc-file-i-have-a-com-ngVlG49FRLGmHiRv.i20CA

ed ~/.bashrc <<!
g/PS1.*033/s/34m/36m/g
g/PS1.*\\\w/s/\\\w/\\\W/g
wq
!
