#!/usr/bin/env bash

# enable showing image previews on File and Desktop GUI


# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# uncomment these lines if you need to ensure this runs under root/sudo
if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit 1
fi


set -x


if ! grep -iq 'GSK_RENDERER=gl' /etc/environment
then
	echo Adding GSK_RENDERER to /etc/environment
	echo "GSK_RENDERER=gl" >> /etc/environment
fi

echo "Installing gnome-sushi"
apt install gnome-sushi

echo "Installing ffmpegthumbnailer"
apt install -y ffmpegthumbnailer
mkdir -p ~/.config/nautilus/thumbnailers
ln -sf /usr/share/thumbnailers/ffmpegthumbnailer.thumbnailer ~/.config/nautilus/thumbnailers/ffmpegthumbnailer.thumbnailer

echo "Removing old thumbnails/fail files"
rm -rf ~/.cache/thumbnails/fail

echo "-------------------------------"
echo "You should now log off back on"
echo "-------------------------------"
# read -p "hit Enter to continue: " enter
# echo $enter

# systemctl restart gdm.service
