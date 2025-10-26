#!/usr/bin/env bash

# install FreeLing: free linguistic analyses (binary code package)


# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# uncomment these lines if you need to ensure this runs under root/sudo
if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit 1
fi

#set -x


echo Installing essentials ...

apt-get install -y build-essential
apt-get install -y cmake


echo Installing additional libraries ...

apt-get install -y libboost-dev libboost-regex-dev libicu-dev libboost-system-dev libboost-program-options-dev libboost-thread-dev zlib1g-dev \
	libboost-filesystem-dev


echo Downloading tar file ...

export FLINSTALL=/home/calang/installed/FreeLing-4.2
cd $(dirname $FLINSTALL)

if [ ! -d $FLINSTALL ]
then
	echo to download ...
	wget https://github.com/TALP-UPC/FreeLing/archive/refs/tags/4.2.tar.gz -o FreeLing-4.2.tar.gz
	tar -x -f FreeLing-4.2.tar.gz \
	&& rm FreeLing-4.2.tar.gz
	mv FreeLing-4.2 FreeLing-4.2
else
	echo already downloaded.
fi


echo Building FreeLing ...
set -x

cd $FLINSTALL

mkdir -p build
pwd

cmake -B build -DCMAKE_INSTALL_PREFIX=$FLINSTALL -Wno-dev # -DPYTHON3_API=ON

cd build

# NOTE: edited $FLINSTALL/CMakeLists.txt:
# on line 39 (uncommenting the second line)
	# --- PATCH for Ubuntu 24.10 ---
	# find_package(Boost)

make -j 10 install


