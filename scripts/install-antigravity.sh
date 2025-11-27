#!/bin/bash
# Install Antigravity for Ubuntu
# Based on instructions from https://antigravity.google/download/linux

# exit on any command failure
# or usage of undefined variable
# or failure of any command within a pipeline
set -euo pipefail

# uncomment these lines if you need to ensure this runs under root/sudo
if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit 1
fi

echo "Installing Antigravity..."

# Ensure keyring directory exists
mkdir -p /etc/apt/keyrings

# Add the Antigravity repository key
echo "Adding Antigravity repository key..."

curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | \
  gpg --dearmor -o /etc/apt/keyrings/antigravity-repo-key.gpg

# wget -q -O - https://antigravity.google/linux/linux_signing_key.pub | sudo apt-key add -

# Add the Antigravity repository
echo "Adding Antigravity repository..."
echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | \
  tee /etc/apt/sources.list.d/antigravity.list > /dev/null

# sudo sh -c 'echo "deb [arch=amd64] https://antigravity.google/linux/deb stable main" \
#   > /etc/apt/sources.list.d/antigravity.list'

# Update package lists
echo "Updating package lists..."
apt-get update

# Install Antigravity
echo "Installing Antigravity package..."
apt-get install -y antigravity

echo "Antigravity installation completed successfully!"
echo "You can launch Antigravity from your applications menu or by running 'antigravity' in the terminal."

