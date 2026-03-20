#!/usr/bin/env bash
#
# install-PACKAGE.sh - Install PACKAGE_NAME
#
# Description:
#   Brief description of what this package does and why you might install it.
#   Include any important notes about the installation.
#
# Requirements:
#   - Ubuntu 24.04 (or specify other versions)
#   - sudo privileges (or specify if it should run as regular user)
#   - Internet connection
#   - List any dependencies (e.g., Java, Python, etc.)
#
# Usage:
#   sudo scripts/install-PACKAGE.sh
#   OR
#   scripts/install-PACKAGE.sh  # if no sudo required
#
# Installation Method:
#   [APT | Snap | Direct Download | Custom Repository | Source Build]
#

# Load common functions and error handling
source "$(dirname "$0")/lib/common.sh"

# ============================================================================
# Configuration
# ============================================================================

# Package name(s) to install
PACKAGE_NAME="package"
# APT_PACKAGES=("package1" "package2")

# Version to install (if applicable, otherwise remove)
# VERSION="1.2.3"

# URLs for downloads (if applicable)
# DOWNLOAD_URL="https://example.com/package.deb"

# ============================================================================
# Pre-flight Checks
# ============================================================================

print_header "Installing $PACKAGE_NAME"

# Check privileges (choose one)
require_root          # For installations requiring sudo
# require_non_root    # For per-user installations

# Check dependencies (if any)
# require_command "java" "Please install Java first: make java"
# require_command "conda" "Please install mamba first: make mamba"

# Check if already installed
if check_already_installed "$PACKAGE_NAME"; then
    log_info "$PACKAGE_NAME is already installed"

    # Optionally show version
    if check_command "$PACKAGE_NAME"; then
        log_info "Current version: $($PACKAGE_NAME --version 2>&1 | head -n 1)"
    fi

    # Ask if user wants to reinstall (optional)
    # if ask_yes_no "Reinstall anyway?" "no"; then
    #     log_step "Proceeding with reinstallation"
    # else
    #     log_info "Skipping installation"
    #     exit 0
    # fi

    exit 0
fi

# ============================================================================
# Installation
# ============================================================================

# Choose one of the following installation methods:

# --- Method 1: APT Package ---
# log_step "Installing via APT..."
# ensure_apt_packages "${APT_PACKAGES[@]}"

# --- Method 2: Snap Package ---
# log_step "Installing via Snap..."
# ensure_snap_package "$PACKAGE_NAME"
# OR with flags:
# ensure_snap_package "$PACKAGE_NAME" "--classic"

# --- Method 3: Direct Download + dpkg ---
# log_step "Downloading package..."
# download_if_missing "$DOWNLOAD_URL"
# log_step "Installing package..."
# dpkg -i "$(basename "$DOWNLOAD_URL")"
# cleanup_file "$(basename "$DOWNLOAD_URL")"

# --- Method 4: Add Repository then Install ---
# add_apt_repository \
#     "package-name" \
#     "https://example.com/keys/key.gpg" \
#     "deb [arch=amd64 signed-by=/etc/apt/keyrings/package-name.gpg] https://example.com/repo stable main"
# ensure_apt_package "$PACKAGE_NAME"

# --- Method 5: Download and Execute Installer Script ---
# log_step "Downloading installer..."
# download_if_missing "https://example.com/install.sh"
# chmod +x install.sh
# log_step "Running installer..."
# ./install.sh
# cleanup_file "install.sh"

# ============================================================================
# Post-Installation
# ============================================================================

# Verify installation
if check_command "$PACKAGE_NAME"; then
    log_success "$PACKAGE_NAME installed successfully"

    # Record version in manifest
    record_version "$PACKAGE_NAME" "$PACKAGE_NAME --version"

    # Show installed version
    if check_command "$PACKAGE_NAME"; then
        log_info "Installed version: $($PACKAGE_NAME --version 2>&1 | head -n 1)"
    fi

    # Optional: Run post-install configuration
    # log_step "Running post-install configuration..."
    # $PACKAGE_NAME --configure

    # Provide next steps or usage hints
    echo
    log_info "Next steps:"
    log_info "  1. Configure the package: <command>"
    log_info "  2. Start using: <command>"

    # Optional: Show additional resources
    # log_info "Documentation: https://example.com/docs"
    # log_info "Recommended extensions/plugins: <list>"

else
    log_error "$PACKAGE_NAME installation failed"
    log_info "Check the log file: $LOG_FILE"
    log_info "Try running: sudo apt-get install -f  # to fix any dependency issues"
    exit 1
fi

print_separator

# ============================================================================
# Cleanup (if needed)
# ============================================================================

# Clean up any temporary files
# cleanup_file "temp-file.txt"

# Optional: Create configuration file or symlinks
# log_step "Creating configuration..."
# mkdir -p ~/.config/$PACKAGE_NAME
# cp default-config.yml ~/.config/$PACKAGE_NAME/config.yml

