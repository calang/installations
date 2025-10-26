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


# enable color support of ls and also add handy aliases
# encoding: https://www.perplexity.ai/search/in-my-bashrc-file-i-have-a-com-ngVlG49FRLGmHiRv.i20CA

if [ -x /usr/bin/dircolors ]
then
	dircolors -p >~/.dircolors
	# change blue with cyan
	ed ~/.dircolors <<-!
		1,\$s/34;/36;/g
		1,\$s/;34/;36/g
		wq
	!
fi
