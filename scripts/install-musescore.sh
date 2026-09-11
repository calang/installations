#!/usr/bin/env bash

# install musescore, to execute under fuse


# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# uncomment these lines if you need to ensure this runs under root/sudo
# if [ "$EUID" -ne 0 ]
# 	then echo "Please run as root"
# 	exit 1
# fi


#set -x

DOWNLOADS=$HOME/Downloads

echo "--------------"
echo "1. Download the latest version of musescore for Ubuntu on $DOWNLOADS"
echo "2. Then, continue running this script"
echo
read -p "hit Enter to continue" enter
google-chrome https://musescore.org/en/download/musescore-x86_64.AppImage
echo 
read -p "hit Enter, once the image has been downloaded" enter

set -x

LAST_DOWNLOAD=$(find "$DOWNLOADS" -maxdepth 1 -name 'MuseScore-Studio*-x86_64.AppImage' -printf '%T@ %p\n' | sort -n | tail -1 | cut -d' ' -f2-)

# echo last: "|$LAST_DOWNLOAD|"

chmod +x $LAST_DOWNLOAD

rm -rf $HOME/.local/bin/musescore
rm -rf $HOME/.local/bin/musescore4portable
rm -rf $HOME/.local/bin/MuseScore-Studio*-x86_64.AppImage

cp $LAST_DOWNLOAD $HOME/.local/bin/
APPIMAGE=`basename $LAST_DOWNLOAD`
ln -s $HOME/.local/bin/$APPIMAGE $HOME/.local/bin/musescore4portable
ln -s $HOME/.local/bin/musescore4portable $HOME/.local/bin/musescore
