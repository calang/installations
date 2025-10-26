#!/usr/bin/env bash

# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# install jupyterlab in mamba base environment


# # uncomment these lines if you need to ensure this runs under root/sudo
# if [ "$EUID" -ne 0 ]
# 	then echo "Please run as root"
# 	exit 1
# fi


if ! mamba env list | grep -E '^base' | grep '*'
then
	echo You must be using the base mamba/conda env to run this script
	exit 1
fi


set -x


if ! conda list -n base | grep jupyter-swi-prolog
then
	pip install jupyter-swi-prolog
fi


SP_PATH=$(find $CONDA_PREFIX/lib -name site-packages -print)

jupyter kernelspec install --user $SP_PATH/swi_prolog_kernel
