#!/usr/bin/env bash

# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# install pgadmin


# uncomment these lines if you need to ensure this runs under root/sudo
if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit 1
fi


set -x

echo "Update packages"

apt update
apt upgrade -y


# echo "Add the pgAdmin repository's public key and repository configuration"

curl -fsSL https://www.pgadmin.org/static/packages_pgadmin_org.pub | gpg --dearmor -o /usr/share/keyrings/pgadmin4.gpg

[ -f /etc/apt/sources.list.d/pgadmin4.list ] || \
sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/pgadmin4.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list'


echo "Update the package list again and install pgAdmin (for web mode)"

apt update
apt install -y pgadmin4-web


echo "Run the setup script to configure pgAdmin"

/usr/pgadmin4/bin/setup-web.sh


echo "Access pgAdmin through your web browser using: \
	http://localhost/pgadmin4"
