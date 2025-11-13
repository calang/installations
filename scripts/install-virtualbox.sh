#!/usr/bin/env bash

# exit on any command failure
# or usage of undefined variable
# or failure of any command within a pipeline
set -euo pipefail


# install Oracle VirtualBox


# uncomment these lines if you need to ensure this runs under root/sudo
if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit 1
fi

set -x

# Determine the appropriate Ubuntu release for VirtualBox repository
CURRENT_RELEASE=$(lsb_release -cs)

# Check if we should use Ubuntu's native packages or Oracle repository
case "$CURRENT_RELEASE" in
  questing|plucky|oracular)
    # Ubuntu 25.10, 25.04, 24.10 have VirtualBox in their repos
    echo "Using Ubuntu's native VirtualBox packages for release '$CURRENT_RELEASE'"
    USE_UBUNTU_REPO=true
    # Remove Oracle VirtualBox repository if it exists
    rm -f /etc/apt/sources.list.d/virtualbox.list
    rm -f /usr/share/keyrings/virtualbox-keyring.gpg
    ;;
  *)
    # For older releases, use Oracle repository
    echo "Using Oracle VirtualBox repository for release '$CURRENT_RELEASE'"
    USE_UBUNTU_REPO=false

    # Remove old VirtualBox repository file and GPG key if they exist
    rm -f /etc/apt/sources.list.d/virtualbox.list
    rm -f /usr/share/keyrings/virtualbox-keyring.gpg

    # Add the Oracle GPG key
    curl -fsSL https://www.virtualbox.org/download/oracle_vbox_2016.asc \
      | gpg --dearmor -o /usr/share/keyrings/virtualbox-keyring.gpg

    # Add the VirtualBox repository
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/virtualbox-keyring.gpg] \
      https://download.virtualbox.org/virtualbox/debian $CURRENT_RELEASE contrib" \
      | tee /etc/apt/sources.list.d/virtualbox.list
    ;;
esac

# Update package list
apt update

# Install VirtualBox and Extension Pack
# Note: virtualbox-ext-pack installation will prompt for license acceptance
# Use Tab to navigate to <Ok> and press Enter
if [ "$USE_UBUNTU_REPO" = true ]; then
  # Use Ubuntu's packages (no version suffix)
  apt install -y virtualbox virtualbox-ext-pack virtualbox-qt virtualbox-guest-additions-iso
else
  # Use Oracle's packages (with version suffix)
  apt install -y virtualbox-7.0 virtualbox-ext-pack virtualbox-guest-additions-iso
fi

# Add the current user to vboxusers group
# This allows VirtualBox to access USB devices
if [ -n "${SUDO_USER:-}" ]; then
	usermod -aG vboxusers "$SUDO_USER"
	echo "Added user $SUDO_USER to vboxusers group"
else
	echo "Warning: SUDO_USER not set. Please run: sudo usermod -aG vboxusers \$USER"
fi

set +x
echo ""
echo "=========================================="
echo "VirtualBox installation completed!"
echo "=========================================="
echo ""
echo "IMPORTANT: Please reboot your computer to:"
echo "  - Apply the vboxusers group changes"
echo "  - Load VirtualBox kernel modules"
echo ""
echo "After reboot, verify installation with:"
echo "  virtualbox --help"
echo ""

