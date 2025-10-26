#!/usr/bin/env bash

# exit on any command failure
# or usage of undefined variable
# or failure of any command within a pipeline
set -euo pipefail


# install LibreOffice with common components


# uncomment these lines if you need to ensure this runs under root/sudo
if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit 1
fi

set -x


# Update package list
apt-get update

# Install LibreOffice with common components
apt-get install -y \
	libreoffice \
	libreoffice-writer \
	libreoffice-calc \
	libreoffice-impress \
	libreoffice-draw \
	libreoffice-math \
	libreoffice-base \
	libreoffice-help-en-us \
	libreoffice-l10n-en-us

# Optional: Install additional extensions and templates
apt-get install -y \
	libreoffice-style-breeze \
	libreoffice-gnome

set +x

echo "LibreOffice installation complete!"
echo "You can launch it from the applications menu or use commands like:"
echo "  libreoffice --writer (for Writer)"
echo "  libreoffice --calc (for Calc)"
echo "  libreoffice --impress (for Impress)"

