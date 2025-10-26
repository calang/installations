#!/usr/bin/env bash

# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# install postgres


# uncomment these lines if you need to ensure this runs under root/sudo
if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit 1
fi


echo "--- Installing Postgres ---"

echo "Updating package lists"
apt-get update

echo "Installing Postgres and contrib packages"
apt-get install -y postgresql postgresql-contrib

echo "Enable PostgreSQL to start automatically at system boot time"
systemctl enable postgresql
# or systemctl disable postgresql, to disable this function

echo "Starting Postgres service"
systemctl start postgresql

echo "Test Postgres installation"
systemctl status postgresql | grep "active" >/dev/null

echo "Creating user calang"
sudo -u postgres createuser --superuser calang

echo "Creating database tt"
# -u postgres (used with sudo):
# Runs the command as the postgres system user,
# which has permission to manage PostgreSQL roles and databases.
# -O calang (used with createdb):
# Specifies that the new database should be owned by the PostgreSQL role/user calang.
sudo -u postgres createdb -O calang tt
