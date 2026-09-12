#!/usr/bin/env bash
#
# install-fwupd.sh - Install fwupd
#
# Description:
#   fwupd is a daemon for managing firmware updates on Linux, used by
#   tools like GNOME Software and the fwupdmgr CLI to check for and
#   apply firmware updates from the Linux Vendor Firmware Service (LVFS).
#
# Requirements:
#   - Ubuntu 24.04
#   - sudo privileges
#   - Internet connection
#
# Usage:
#   sudo scripts/install-fwupd.sh
#
# Installation Method:
#   APT
#

# Load common functions and error handling
source "$(dirname "$0")/lib/common.sh"

# ============================================================================
# Configuration
# ============================================================================

PACKAGE_NAME="fwupd"

# ============================================================================
# Pre-flight Checks
# ============================================================================

print_header "Installing $PACKAGE_NAME"

require_root

if check_already_installed "fwupdmgr"; then
    log_info "Current version: $(fwupdmgr --version 2>&1 | head -n 1)"
    exit 0
fi

# ============================================================================
# Installation
# ============================================================================

log_step "Installing via APT..."
ensure_apt_package "$PACKAGE_NAME"

# ============================================================================
# Post-Installation
# ============================================================================

if check_command "fwupdmgr"; then
    log_success "$PACKAGE_NAME installed successfully"

    record_version "$PACKAGE_NAME" "fwupdmgr --version"

    log_info "Installed version: $(fwupdmgr --version 2>&1 | head -n 1)"

    echo
    log_info "Next steps:"
    log_info "  1. Refresh metadata: fwupdmgr refresh"
    log_info "  2. Check for updates: fwupdmgr get-updates"
    log_info "  3. Apply updates: fwupdmgr update"
else
    log_error "$PACKAGE_NAME installation failed"
    log_info "Check the log file: $LOG_FILE"
    log_info "Try running: sudo apt-get install -f  # to fix any dependency issues"
    exit 1
fi

print_separator
