#!/usr/bin/env bash
#
# install-nvm.sh - Install NVM (Node Version Manager) globally
#
# Description:
#   Installs NVM system-wide under /usr/local/nvm and makes it available to
#   all users via /etc/profile.d/nvm.sh. After installing NVM, installs the
#   latest LTS version of Node.js and sets it as the default.
#
# Requirements:
#   - Ubuntu 24.04+
#   - sudo privileges
#   - Internet connection
#   - curl
#
# Usage:
#   sudo scripts/install-nvm.sh
#
# Installation Method:
#   Official NVM installer script with NVM_DIR overridden to /usr/local/nvm
#

# Load common functions and error handling
source "$(dirname "$0")/lib/common.sh"

# ============================================================================
# Configuration
# ============================================================================

PACKAGE_NAME="nvm"
NVM_DIR="/usr/local/nvm"
NVM_PROFILE="/etc/profile.d/nvm.sh"

# ============================================================================
# Pre-flight Checks
# ============================================================================

print_header "Installing $PACKAGE_NAME (system-wide)"

require_root
require_command "curl" "Please install curl first: sudo apt-get install -y curl"

if [ -s "${NVM_DIR}/nvm.sh" ]; then
    log_info "NVM is already installed at ${NVM_DIR}"
    # shellcheck source=/dev/null
    source "${NVM_DIR}/nvm.sh"
    log_info "Current version: $(nvm --version)"
    exit 0
fi

# ============================================================================
# Installation
# ============================================================================

log_step "Creating NVM directory: ${NVM_DIR}"
mkdir -p "${NVM_DIR}"

log_step "Downloading and running NVM installer..."
# Set NVM_DIR before running installer so it installs to the global location.
# PROFILE=/dev/null prevents the installer from modifying any user dotfiles.
export NVM_DIR
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh \
    | PROFILE=/dev/null bash

# ============================================================================
# System-wide profile script
# ============================================================================

log_step "Creating system-wide profile entry: ${NVM_PROFILE}"
cat > "${NVM_PROFILE}" <<'EOF'
# NVM (Node Version Manager) - system-wide initialization
export NVM_DIR="/usr/local/nvm"
# shellcheck source=/dev/null
[ -s "${NVM_DIR}/nvm.sh" ] && source "${NVM_DIR}/nvm.sh"
[ -s "${NVM_DIR}/bash_completion" ] && source "${NVM_DIR}/bash_completion"
EOF

chmod 644 "${NVM_PROFILE}"

# ============================================================================
# Install latest LTS Node.js
# ============================================================================

log_step "Loading NVM..."
# shellcheck source=/dev/null
source "${NVM_DIR}/nvm.sh"

log_step "Installing latest LTS version of Node.js..."
nvm install --lts

log_step "Setting latest LTS as default..."
nvm alias default 'lts/*'

# ============================================================================
# Post-Installation
# ============================================================================

if check_command "nvm"; then
    log_success "NVM installed successfully: $(nvm --version)"
    log_success "Node.js: $(node --version)"
    log_success "npm: $(npm --version)"

    record_version "nvm" "nvm --version"
    record_version "node" "node --version"
    record_version "npm" "npm --version"

    echo
    log_info "Next steps:"
    log_info "  Reload your shell or run: source /etc/profile.d/nvm.sh"
    log_info "  Install other Node versions with: nvm install <version>"
else
    log_error "NVM installation failed"
    log_info "Check the log file: ${LOG_FILE}"
    exit 1
fi

print_separator
