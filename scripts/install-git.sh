#!/usr/bin/env bash
#
# install-git.sh - Install Git, GitK, and Git-GUI (EXAMPLE REFACTORED VERSION)
#
# Description:
#   This script installs Git version control system and its GUI tools.
#   This is an example of how scripts should be refactored using the common library.
#
# Requirements:
#   - Ubuntu 24.04
#   - sudo privileges
#   - Internet connection
#
# Usage:
#   sudo scripts/install-git.sh
#

# Load common functions and error handling
source "$(dirname "$0")/lib/common.sh"

# Script configuration
PACKAGES=("git" "gitk" "git-gui")

# ============================================================================
# Main Installation
# ============================================================================

print_header "Installing Git and GUI Tools"

# Check privileges
require_root

# Check if already installed
if check_already_installed "git"; then
    log_info "Git is already installed: $(git --version)"
    log_info "Checking for additional packages..."
else
    log_step "Git not found, proceeding with installation"
fi

# Install packages
for package in "${PACKAGES[@]}"; do
    ensure_apt_package "$package"
done

# Verify installation
if check_command "git"; then
    log_success "Git installation completed successfully"
    record_version "git" "git --version"

    # Show installed version
    log_info "Installed version: $(git --version)"

    # Provide next steps
    echo
    log_info "Next steps:"
    log_info "- Configure git user: make git-user"
else
    log_error "Git installation failed"
    exit 1
fi

print_separator

