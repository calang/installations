#!/usr/bin/env bash

# exit on any command failure
# or usage of undefined variable
# or failure of any command within a pipeline
set -euo pipefail

# install Windows11 VirtualBox

# Check for dependencies
if [ ! -f /usr/bin/virtualbox ]; then
  echo "virtualboxx command not found, install VirtualBox before proceeding"
  exit 1
fi


# uncomment these lines if you need to ensure this runs under root/sudo
if [ "$EUID" -eq 0 ]
	then echo "Please run as regular user"
	exit 1
fi

set -x


# --- 1. SET YOUR VARIABLES ---

# Name for the new VM
VM_NAME="Win11-CINDE.cr"

# Full path to your downloaded Windows 11 ISO
ISO_PATH="/home/calang/VirtualBox/ISOs/Win11_25H2_EnglishInternational_x64.iso"
if [ ! -f "$ISO_PATH" ]; then
    echo "Error: ISO file not found at $ISO_PATH"
    exit 1
fi

# Windows user/password you want the script to create
# IMPORTANT: Password must be 8+ chars, with upper, lower, and number.
WIN_USER="calang"
WIN_PASSWORD="Cinde2025!"

# VM Hardware Settings
VM_CPUS=4
VM_RAM=16384 # in MB (16 GB)
VM_DISK_SIZE=102400 # in MB (100 GB)

# --- 2. CHECK IF VM ALREADY EXISTS ---
echo "Checking if VM '$VM_NAME' already exists..."

if VBoxManage showvminfo "$VM_NAME" &>/dev/null; then
    echo ""
    echo "=========================================="
    echo "WARNING: VM '$VM_NAME' already exists!"
    echo "=========================================="
    echo ""

    # Temporarily disable exit on error for user input
    set +e

    read -p "Do you want to remove the existing VM and continue? (yes/no): " response

    # Re-enable exit on error
    set -e

    case "$response" in
        [Yy]|[Yy][Ee][Ss])
            echo "Removing existing VM '$VM_NAME'..."

            # Power off VM if running
            if VBoxManage showvminfo "$VM_NAME" | grep -q "State:.*running"; then
                echo "Powering off running VM..."
                VBoxManage controlvm "$VM_NAME" poweroff || true
                sleep 2
            fi

            # Unregister and delete the VM with all files
            VBoxManage unregistervm "$VM_NAME" --delete
            echo "Existing VM removed successfully."
            echo ""
            ;;
        *)
            echo ""
            echo "=========================================="
            echo "Installation cancelled by user."
            echo "Existing VM '$VM_NAME' was not modified."
            echo "=========================================="
            exit 0
            ;;
    esac
fi

# --- 3. CREATE THE VM ---
echo "Creating VM: $VM_NAME..."

# Create the VM with EFI firmware
VBoxManage createvm \
    --name "$VM_NAME" \
    --ostype "Windows11_64" \
    --register

# Configure VM settings
VBoxManage modifyvm "$VM_NAME" \
    --firmware efi \
    --cpus $VM_CPUS \
    --memory $VM_RAM \
    --graphicscontroller vmsvga \
    --vram 128 \
    --tpm-type 2.0 \
    --mouse usbtablet \
    --keyboard usb \
    --audio-driver pulse \
    --audio-enabled on \
    --audioout on \
    --audioin on

# Create and attach storage
VBOX_HOME=$(VBoxManage list systemproperties | grep "^Default machine folder:" | sed 's/Default machine folder: *//')
VM_DISK="$VBOX_HOME/$VM_NAME/${VM_NAME}.vdi"

VBoxManage createmedium disk \
    --filename "$VM_DISK" \
    --size $VM_DISK_SIZE \
    --format VDI

VBoxManage storagectl "$VM_NAME" \
    --name "SATA Controller" \
    --add sata \
    --controller IntelAhci

VBoxManage storageattach "$VM_NAME" \
    --storagectl "SATA Controller" \
    --port 0 \
    --device 0 \
    --type hdd \
    --medium "$VM_DISK"

VBoxManage storagectl "$VM_NAME" \
    --name "IDE Controller" \
    --add ide

VBoxManage storageattach "$VM_NAME" \
    --storagectl "IDE Controller" \
    --port 0 \
    --device 0 \
    --type dvddrive \
    --medium "$ISO_PATH"

# --- 4. RUN UNATTENDED INSTALLATION ---

echo "installing  virtualbox-guest-additions-iso"
dpkg -l | grep virtualbox-guest-additions \
  || apt-get install virtualbox-guest-additions-iso

echo "Starting unattended installation for $VM_NAME..."

# Guest Additions ISO location (optional - VirtualBox will auto-download if not specified)
# If you have a local copy, uncomment and set the path:
# ADDITIONS_ISO="/usr/share/virtualbox/VBoxGuestAdditions.iso"
# Or download it manually from: https://download.virtualbox.org/virtualbox/

VBoxManage unattended install "$VM_NAME" \
    --iso="$ISO_PATH" \
    --image-index=1 \
    --user="$WIN_USER" \
    --user-password="$WIN_PASSWORD" \
    --install-additions \
    --time-zone="America/Costa_Rica" \
    --locale=en_US \
    --country=CR \
    --hostname="${VM_NAME}"
#    --additions-iso="$ADDITIONS_ISO" \
#    --key="XXXXX-XXXXX-XXXXX-XXXXX-XXXXX" \

# --- 5. START THE VM ---
echo "Starting VM installation..."
VBoxManage startvm "$VM_NAME" --type gui

echo "VM creation and installation started."
echo "A new VM window will open and run the automated setup."

set +x
echo ""
echo "=========================================="
echo "Win11-CINDE installation completed!"
echo "=========================================="
