#!/usr/bin/env bash
#
# install-ollama.sh - Install Ollama (local LLM runner)
#
# Description:
#   Installs Ollama using the official install script, per
#   https://docs.ollama.com/linux. The installer places the ollama binary,
#   creates a dedicated "ollama" system user/group, and registers/starts an
#   "ollama" systemd service.
#
# Requirements:
#   - Ubuntu 24.04+
#   - sudo privileges
#   - Internet connection
#   - curl
#
# Usage:
#   sudo scripts/install-ollama.sh
#
# Installation Method:
#   Official Ollama installer script (curl | sh)
#

# Load common functions and error handling
source "$(dirname "$0")/lib/common.sh"

# ============================================================================
# Configuration
# ============================================================================

PACKAGE_NAME="ollama"

# ============================================================================
# Pre-flight Checks
# ============================================================================

print_header "Installing $PACKAGE_NAME"

require_root
require_command "curl" "Please install curl first: sudo apt-get install -y curl"

if check_already_installed "$PACKAGE_NAME"; then
    log_info "$PACKAGE_NAME is already installed"
    log_info "Current version: $(ollama --version 2>&1 | head -n 1)"
    exit 0
fi

# ============================================================================
# Installation
# ============================================================================

log_step "Downloading and running the official Ollama installer..."
curl -fsSL https://ollama.com/install.sh | sh

# ============================================================================
# Post-Installation
# ============================================================================

if check_command "$PACKAGE_NAME"; then
    log_success "$PACKAGE_NAME installed successfully"

    record_version "$PACKAGE_NAME" "ollama --version"
    log_info "Installed version: $(ollama --version 2>&1 | head -n 1)"

    if [ -n "${SUDO_USER:-}" ]; then
        log_step "Adding user $SUDO_USER to the ollama group..."
        usermod -aG ollama "$SUDO_USER"
        log_info "Log out/in for the group change to take effect."
    fi

    echo
    log_info "Next steps:"
    log_info "  Service is managed by systemd: sudo systemctl status ollama"
    log_info "  Pull and run a model: ollama run llama3.2"
    log_info "  View logs: journalctl -e -u ollama"
else
    log_error "$PACKAGE_NAME installation failed"
    log_info "Check the log file: $LOG_FILE"
    exit 1
fi

print_separator
