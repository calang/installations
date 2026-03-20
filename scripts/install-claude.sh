#!/usr/bin/env bash

# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# install claude-code


# uncomment these lines if you need to ensure this runs under root/sudo
# if [ "$EUID" -ne 0 ]
# 	then echo "Please run as root"
# 	exit 1
# fi


set -x

# install
[[ -f install-ccdode.sh ]] || \
	curl -fsSL https://claude.ai/install.sh -o install-ccode.sh

bash install-ccode.sh

echo '
# call claude code

exec ~/.local/bin/claude
' >~/bin/claude

chmod +x ~/bin/claude

rm -f install-ccode.sh


# start
claude --help

