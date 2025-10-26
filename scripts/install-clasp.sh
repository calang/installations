#!/usr/bin/env bash

# install clasp: ASP resolution


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

apt-get install -y build-essential cmake git libboost-all-dev


# echo Installing additional libraries ...

apt-get update
apt-get install -y git cmake g++ bison re2c lua5.4 liblua5.4-dev


echo Clone the Clingo Repository ...

export TMPDIR=/home/calang/proyects/tmp
mkdir -p $TMPDIR
cd $TMPDIR

if [ ! -d clasp ]
then
	echo to clone ...
	git clone https://github.com/potassco/clasp.git
else
	echo already cloned and updated
fi


echo Build clingo ...

cd clasp
mkdir build && cd build
cmake .. -DWITH_THREADS=ON
make -j$(nproc)
make install


echo Verify Installation and Multithreading Support ...

clasp --version
clasp --threads=4

exit
