#!/usr/bin/env bash
#
# install-win11vb.sh - Install a Windows 11 VirtualBox VM
#
# Description:
#   Creates and configures a Windows 11 VirtualBox VM with the given name,
#   with unattended installation using a local ISO, configured for Costa Rica
#   locale and timezone.
#
# Requirements:
#   - Ubuntu 24.04
#   - Regular user (no sudo)
#   - VirtualBox already installed: make virtualbox
#   - Windows 11 ISO downloaded to ~/VirtualBox/ISOs/
#
# Usage:
#   scripts/install-win11vb.sh [VM_NAME]
#
# Installation Method:
#   VBoxManage unattended install
#

# Load common functions and error handling
source "$(dirname "$0")/lib/common.sh"

# ============================================================================
# Configuration
# ============================================================================

# Name for the new VM: use first argument or prompt
if [ -n "${1:-}" ]; then
    VM_NAME="$1"
else
    read -r -p "Enter the name for the new VM: " VM_NAME
    if [ -z "$VM_NAME" ]; then
        log_error "VM name cannot be empty."
        exit 1
    fi
fi

PACKAGE_NAME="$VM_NAME"

# Directory containing Windows ISO images
ISO_DIR="/home/calang/VirtualBox/ISOs"

# Windows user/password you want the script to create
# IMPORTANT: Password must be 8+ chars, with upper, lower, and number.
WIN_USER="calang"
WIN_PASSWORD="Cinde2025!"

# VM Hardware Settings
VM_CPUS=4
VM_RAM=16384   # in MB (16 GB)
VM_DISK_SIZE=102400  # in MB (100 GB)

# Shared folder (host path → drive letter inside Windows)
SHARED_FOLDER_HOST="/home/calang"
SHARED_FOLDER_NAME="calang"
SHARED_FOLDER_DRIVE="Z:"

# ============================================================================
# Pre-flight Checks
# ============================================================================

print_header "Installing $PACKAGE_NAME"

require_non_root

require_command "VBoxManage" "Please install VirtualBox first: make virtualbox"

# Select ISO from available files
mapfile -t ISO_FILES < <(find "$ISO_DIR" -maxdepth 1 -name "*.iso" -type f | sort)

if [ ${#ISO_FILES[@]} -eq 0 ]; then
    log_error "No ISO files found in $ISO_DIR"
    log_info "Download a Windows 11 ISO and place it in $ISO_DIR"
    exit 1
elif [ ${#ISO_FILES[@]} -eq 1 ]; then
    ISO_PATH="${ISO_FILES[0]}"
    log_info "Using ISO: $(basename "$ISO_PATH")"
else
    echo
    log_info "Available ISO files:"
    for i in "${!ISO_FILES[@]}"; do
        echo "  $((i+1))) $(basename "${ISO_FILES[$i]}")"
    done
    echo
    read -r -p "Select ISO [1-${#ISO_FILES[@]}]: " iso_choice
    if ! [[ "$iso_choice" =~ ^[0-9]+$ ]] || [ "$iso_choice" -lt 1 ] || [ "$iso_choice" -gt ${#ISO_FILES[@]} ]; then
        log_error "Invalid selection: $iso_choice"
        exit 1
    fi
    ISO_PATH="${ISO_FILES[$((iso_choice-1))]}"
    log_info "Using ISO: $(basename "$ISO_PATH")"
fi

# Check if VM already exists
log_step "Checking if VM '$VM_NAME' already exists..."

if VBoxManage showvminfo "$VM_NAME" &>/dev/null; then
    log_warn "VM '$VM_NAME' already exists!"

    if ask_yes_no "Remove the existing VM and continue?" "no"; then
        log_step "Removing existing VM '$VM_NAME'..."

        if VBoxManage showvminfo "$VM_NAME" | grep -q "State:.*running"; then
            log_step "Powering off running VM..."
            VBoxManage controlvm "$VM_NAME" poweroff || true
            sleep 2
        fi

        VBoxManage unregistervm "$VM_NAME" --delete
        log_success "Existing VM removed."
    else
        log_info "Installation cancelled. Existing VM '$VM_NAME' was not modified."
        exit 0
    fi
fi

# ============================================================================
# Installation
# ============================================================================

log_step "Creating VM: $VM_NAME..."

VBoxManage createvm \
    --name "$VM_NAME" \
    --ostype "Windows11_64" \
    --register

log_step "Configuring VM settings..."

VBoxManage modifyvm "$VM_NAME" \
    --firmware efi \
    --cpus $VM_CPUS \
    --memory $VM_RAM \
    --graphicscontroller vboxsvga \
    --vram 128 \
    --tpm-type 2.0 \
    --mouse usbtablet \
    --keyboard usb \
    --audio-driver pulse \
    --audio-enabled on \
    --audioout on \
    --audioin on

log_step "Configuring clipboard, drag-and-drop, and shared folder..."

VBoxManage modifyvm "$VM_NAME" \
    --clipboard-mode bidirectional \
    --drag-and-drop bidirectional

VBoxManage sharedfolder add "$VM_NAME" \
    --name "$SHARED_FOLDER_NAME" \
    --hostpath "$SHARED_FOLDER_HOST" \
    --automount \
    --auto-mount-point "$SHARED_FOLDER_DRIVE"

log_step "Creating and attaching storage..."

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

log_step "Ensuring virtualbox-guest-additions-iso is installed..."
ensure_apt_package "virtualbox-guest-additions-iso"

log_step "Starting unattended installation for $VM_NAME..."

# Guest Additions ISO location (optional - VirtualBox will auto-download if not specified)
# If you have a local copy, uncomment and set the path:
# ADDITIONS_ISO="/usr/share/virtualbox/VBoxGuestAdditions.iso"

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

log_step "Starting VM..."
VBoxManage startvm "$VM_NAME" --type gui

# ============================================================================
# Post-Installation
# ============================================================================

log_success "$PACKAGE_NAME VM created and installation started."

echo
log_info "Next steps:"
log_info "  1. Complete Windows setup in the VM window that just opened"
log_info "     - Choose Win11 Pro for Workstations"
log_info "     - Install Guest Additions inside Windows"
log_info "       1. In the VirtualBox menu: Devices → Insert Guest Additions CD image..."
log_info "       2. Inside Windows, open File Explorer → find the mounted CD drive (usually D:)"
log_info "       3. Run VBoxWindowsAdditions.exe"
log_info "       4. Follow the installer — reboot when prompted"
log_info "     - After reboot, View → Auto-resize Guest Display, which should work automatically from then on."
log_info "  2. Login with user: $WIN_USER"

print_separator
