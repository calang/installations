#!/usr/bin/env bash
#
# install-obsidian.sh - Install Obsidian note-taking app
#
# Description:
#   Installs Obsidian, a knowledge base and note-taking app that works on
#   local Markdown files. Installed via official .deb package from GitHub.
#
# Requirements:
#   - Ubuntu 24.04+
#   - sudo privileges
#   - Internet connection
#   - wget
#
# Usage:
#   sudo scripts/install-obsidian.sh
#
# Installation Method:
#   Direct Download (.deb from GitHub releases) + dpkg
#

# Load common functions and error handling
source "$(dirname "$0")/lib/common.sh"

# ============================================================================
# Configuration
# ============================================================================

PACKAGE_NAME="obsidian"
VERSION="1.8.10"
DEB_FILE="${PACKAGE_NAME}_${VERSION}_amd64.deb"
DOWNLOAD_URL="https://github.com/obsidianmd/obsidian-releases/releases/download/v${VERSION}/${DEB_FILE}"

# ============================================================================
# Pre-flight Checks
# ============================================================================

print_header "Installing $PACKAGE_NAME"

require_root
require_command "wget" "Please install wget first: sudo apt-get install -y wget"

if is_package_installed "$PACKAGE_NAME"; then
    log_info "$PACKAGE_NAME is already installed"
    exit 0
fi

# ============================================================================
# Installation
# ============================================================================

log_step "Downloading $DEB_FILE..."
download_if_missing "$DOWNLOAD_URL" "$DEB_FILE"

log_step "Installing $DEB_FILE..."
dpkg -i "$DEB_FILE" || true

log_step "Fixing any broken dependencies..."
apt-get install -f -y

cleanup_file "$DEB_FILE"

# ============================================================================
# Post-Installation
# ============================================================================

if is_package_installed "$PACKAGE_NAME"; then
    log_success "$PACKAGE_NAME installed successfully"
    record_version "$PACKAGE_NAME" "dpkg -l obsidian | grep '^ii' | awk '{print \$3}'"

    echo
    log_info "Launch Obsidian from the applications menu or run: obsidian"
else
    log_error "$PACKAGE_NAME installation failed"
    log_info "Check the log file: $LOG_FILE"
    log_info "Try running: sudo apt-get install -f"
    exit 1
fi

print_separator
