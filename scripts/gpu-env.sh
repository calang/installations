#!/usr/bin/env bash

# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# create conda env for gpu target


# # uncomment these lines if you need to ensure this runs under root/sudo
# if [ "$EUID" -ne 0 ]
# 	then echo "Please run as root"
# 	exit 1
# fi

set -x



CONDA_ENV=$1


echo Set conda environment

if conda env list | grep $CONDA_ENV
then
	conda env remove -y -n $CONDA_ENV
fi 

conda env create -n $CONDA_ENV -f scripts/environment.yml
