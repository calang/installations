#!/bin/bash



. .venv/bin/activate

pip install tensorflow
pip install torch

# install NVIDIA driver
sudo ubuntu-drivers autoinstall
# need to reboot !!!


# install NVIDIA commands
# sudo apt install -y nvidia-utils-535
 

# check access to NVIDIA GPU
./check_nvidia.py

