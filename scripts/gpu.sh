#!/usr/bin/env bash

# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# fix links to nvidia gpu libraries


# uncomment these lines if you need to ensure this runs under root/sudo
if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit 1
fi

# set -x


echo "Conda init"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/calang/installed/miniforge3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/calang/installed/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/home/calang/installed/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/home/calang/installed/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup

if [ -f "/home/calang/installed/miniforge3/etc/profile.d/mamba.sh" ]; then
    . "/home/calang/installed/miniforge3/etc/profile.d/mamba.sh"
fi
# <<< conda initialize <<<

set -x


CONDA_ENV=$1

conda activate $CONDA_ENV


echo Create symbolic links to NVIDIA shared libraries

pushd $(dirname $(python -c 'print(__import__("tensorflow").__file__)'))
ln -svf ../nvidia/*/lib/*.so* .
popd


# echo Create a symbolic link to ptxas

# ln -sf $(find $(dirname $(dirname $(python -c "import nvidia.cuda_nvcc;         
# print(nvidia.cuda_nvcc.__file__)"))/*/bin/) -name ptxas -print -quit) $CONDA_ENV/bin/ptxas


echo Verify the GPU setup
python3 -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"
[]
