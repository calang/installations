#!/usr/bin/env bash

# install clingo: ASP resolution


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

echo Install from potassco repo ...

add-apt-repository ppa:potassco/stable
apt-get update
apt-get install clingo

exit 0



echo Installing essentials ...

apt-get install -y build-essential
apt-get install -y cmake


echo Installing additional libraries ...

apt-get update
apt-get install -y git cmake g++ bison re2c lua5.4 liblua5.4-dev


echo Clone the Clingo Repository ...

export TMPDIR=/home/calang/proyects/tmp
mkdir -p $TMPDIR
cd $TMPDIR

export CLINGODIR=/home/calang/proyects/tmp/clingo

if [ ! -d $CLINGODIR ]
then
	echo to clone ...
	git clone https://github.com/potassco/clingo.git
	cd clingo
	git submodule update --init --recursive
else
	echo already cloned and updated
fi


echo Build clingo ...

cd $CLINGODIR
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCLASP_BUILD_WITH_THREADS=On
make -j$(nproc)
make install


echo Verify Installation and Multithreading Support ...

clingo --version
clingo --help | grep threads

exit
