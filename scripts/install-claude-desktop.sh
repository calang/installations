#!/usr/bin/env bash
#
# install-claude-desktop.sh - Install Claude Desktop (Anthropic, beta)
#
# Description:
#   Installs the official Anthropic-provided Claude Desktop app via its APT
#   repository, per https://support.claude.com/en/articles/10065433-install-claude-desktop
#
# Requirements:
#   - Ubuntu 22.04+ or Debian 12+ (x64 or arm64)
#   - sudo privileges
#   - Internet connection
#
# Usage:
#   sudo scripts/install-claude-desktop.sh
#
# Installation Method:
#   APT Repository (official, supports automatic updates)
#

# Load common functions and error handling
source "$(dirname "$0")/lib/common.sh"

# ============================================================================
# Configuration
# ============================================================================

PACKAGE_NAME="claude-desktop"
KEYRING="/usr/share/keyrings/claude-desktop-archive-keyring.asc"
KEY_URL="https://downloads.claude.ai/claude-desktop/key.asc"
REPO_LIST="/etc/apt/sources.list.d/claude-desktop.list"
REPO_LINE="deb [signed-by=${KEYRING}] https://downloads.claude.ai/claude-desktop/apt/stable stable main"
EXPECTED_FINGERPRINT="31DDDE24DDFAB679F42D7BD2BAA929FF1A7ECACE"

# ============================================================================
# Pre-flight Checks
# ============================================================================

print_header "Installing $PACKAGE_NAME"

require_root
require_command "curl" "Please install curl first: sudo apt-get install -y curl"
require_command "gpg" "Please install gpg first: sudo apt-get install -y gnupg"

# Add the invoking user to the kvm group, required for Cowork (runs a QEMU
# workspace VM). Idempotent, so it's safe to run even if already installed.
log_step "Adding user to kvm group (required for Cowork)..."
if [ -n "${SUDO_USER:-}" ]; then
    usermod -aG kvm "$SUDO_USER"
    log_info "Added user $SUDO_USER to kvm group. A REBOOT is required for it to take"
    log_info "effect, not just log out/in: the systemd --user manager that spawns your"
    log_info "desktop session's apps persists across logout/login and caches the old"
    log_info "group list, so a mere re-login is not enough."
else
    log_warn "SUDO_USER not set. Please run: sudo usermod -aG kvm \$USER"
fi

if is_package_installed "$PACKAGE_NAME"; then
    log_info "$PACKAGE_NAME is already installed"
    exit 0
fi

# ============================================================================
# Installation
# ============================================================================

log_step "Adding $PACKAGE_NAME signing key..."
curl -fsSLo "$KEYRING" "$KEY_URL"

log_step "Verifying signing key fingerprint..."
ACTUAL_FINGERPRINT=$(gpg --show-keys --with-colons "$KEYRING" | awk -F: '/^fpr:/ {print $10; exit}')
if [ "$ACTUAL_FINGERPRINT" != "$EXPECTED_FINGERPRINT" ]; then
    log_error "Signing key fingerprint mismatch!"
    log_error "Expected: $EXPECTED_FINGERPRINT"
    log_error "Actual:   $ACTUAL_FINGERPRINT"
    rm -f "$KEYRING"
    exit 1
fi
log_success "Signing key fingerprint verified"

log_step "Adding $PACKAGE_NAME APT repository..."
echo "$REPO_LINE" | tee "$REPO_LIST" > /dev/null

log_step "Updating package lists..."
apt-get update

log_step "Installing $PACKAGE_NAME..."
ensure_apt_package "$PACKAGE_NAME"

# ============================================================================
# Post-Installation
# ============================================================================

if is_package_installed "$PACKAGE_NAME"; then
    log_success "$PACKAGE_NAME installed successfully"
    record_version "$PACKAGE_NAME" "dpkg -l claude-desktop | grep '^ii' | awk '{print \$3}'"

    echo
    log_info "Launch Claude Desktop from the applications menu or run: claude-desktop"
    log_info "Linux (beta) limitations: no Computer Use, no dictation;"
    log_info "Quick Entry hotkey requires X11 (Wayland needs the GlobalShortcuts portal)"
    log_info "Cowork requires KVM hardware virtualization enabled in BIOS/UEFI,"
    log_info "~25 GB free disk, and 8+ GB RAM. Reboot for the kvm group to apply."
else
    log_error "$PACKAGE_NAME installation failed"
    log_info "Check the log file: $LOG_FILE"
    log_info "Try running: sudo apt-get install -f"
    exit 1
fi

print_separator
