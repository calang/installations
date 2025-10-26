#!/usr/bin/env bash

# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# uninstall docker desktop

# references: 
# https://docs.docker.com/desktop/uninstall/


# Notes:


# uncomment these lines if you need to ensudre this runs under root/sudo
if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit 1
fi

set -x

echo '--- to be tested ---'


sysctl -w kernel.apparmor_restrict_unprivileged_unconfined=1
sysctl -w kernel.apparmor_restunprivileged_userns=1

apt remove docker-desktop

rm -rf $HOME/.docker/desktop
# rm -rf /usr/local/bin/com.docker.cli

apt purge docker-desktop
