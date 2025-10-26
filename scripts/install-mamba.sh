#!/usr/bin/env bash

# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# install mamba


# uncomment these lines if you need to ensure this runs under root/sudo
# if [ "$EUID" -ne 0 ]
# 	then echo "Please run as root"
# 	exit 1
# fi

set -x


if which mamba
then
	echo "mamba already installed"
	exit 0
fi


[[ -f Miniforge3-Linux-x86_64.sh ]] \
|| wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh

DEST=~/installed/miniforge3

rm -rf $DEST

bash Miniforge3-Linux-x86_64.sh -b -p $DEST \
&& $DEST/bin/mamba init \
&& rm Miniforge3-Linux-x86_64.sh

# Apply the changes
source ~/.bashrc
CONDA=$DEST/bin/conda

# Install the conda-libmamba-solver for faster dependency resolution
$CONDA install -n base -y conda-libmamba-solver

# Set Mamba as the default solver for Conda
$CONDA config --set solver libmamba
