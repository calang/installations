#!/usr/bin/env bash

# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# install docker desktop

# references: 
# https://docs.docker.com/desktop/install/linux/
# https://docs.docker.com/desktop/install/linux/#kvm-virtualization-support
# https://ubuntu.com/blog/ubuntu-23-10-restricted-unprivileged-user-namespaces
# https://www.docker.com/legal/docker-subscription-service-agreement
# https://www.docker.com/pricing/faq/


# Notes:
# - Docker Desktop installation recommends to stop Docker Engine (if also installed)
#   while running Docker Desktop, to prevent conflicts between them (like using the same port)
# - preconditions:
#   sudo apt install -y cpu-checker # to check kvm availability with kvm-ok
#   sudo usermod -aG kvm $USER  # to add your user to the kvm group in order to access the kvm device
# - latest updates for 24.04
#   sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0 # needs to be run at least once
# - Once a new version for Docker Desktop is released, the Docker UI shows a notification
#   You need to download the new package each time you want to upgrade Docker Desktop and run:
#   sudo apt-get install ./docker-desktop-<arch>.deb


# uncomment these lines if you need to ensudre this runs under root/sudo
if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit 1
fi

set -x


echo Add your user to the kvm group in order to access the kvm 
usermod -aG kvm $USER

echo Add Dockers official GPG key:
apt-get update -y
apt-get install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Get Ubuntu release codename dynamically from /etc/os-release
. /etc/os-release

echo Add the repository to Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  ${VERSION_CODENAME} stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y

[[ -f docker-desktop-amd64.deb ]] \
|| wget https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb


echo Install Docker Desktop
apt-get update -y
apt-get install -y ./docker-desktop-amd64.deb
echo '-- ignore the above   N: Download is ...  message'


echo enable Docker Desktop to start on sign in
systemctl --user enable docker-desktop


echo "
-----
Run the following, in a regular user session, to enable the login:

gpg --generate-key
pass init <your_generated_gpg-id_public_key>


ref: https://docs.docker.com/desktop/get-started/#credentials-management-for-linux-users
-----
"

