#! /usr/bin/env python3

import subprocess

def check_nvidia():
    # Check if NVIDIA GPU is available
    try:
        nvidia_smi_output = subprocess.check_output(['nvidia-smi'], stderr=subprocess.STDOUT)
        print("NVIDIA GPU detected:")
        print(nvidia_smi_output.decode())
        
        # Check if TensorFlow can access the GPU
        try:
            import tensorflow as tf
            if tf.config.list_physical_devices('GPU'):
                print("TensorFlow can access the GPU.")
            else:
                print("TensorFlow cannot access the GPU.")
        except ImportError:
            print("TensorFlow is not installed.")
        
        # Check if PyTorch can access the GPU
        try:
            import torch
            if torch.cuda.is_available():
                print("PyTorch can access the GPU.")
            else:
                print("PyTorch cannot access the GPU.")
        except ImportError:
            print("PyTorch is not installed.")

    except subprocess.CalledProcessError as e:
        print("NVIDIA GPU not detected or nvidia-smi command failed.")
        print(e.output.decode())

if __name__ == "__main__":
    check_nvidia()

