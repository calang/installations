#!/usr/bin/env bash
#
# install-yt-dlp.sh - Install yt-dlp (per user, via pipx)
#
# Description:
#   yt-dlp downloads audio/video from YouTube and other sites.
#   The apt version is usually outdated, so it is installed with pipx.
#   ffmpeg is required to extract/convert audio (e.g. -x --audio-format mp3).
#   Re-running the script upgrades yt-dlp (fixes most download failures).
#
# Requirements:
#   - Ubuntu 24.04
#   - sudo privileges (only to install pipx/ffmpeg if missing)
#   - Internet connection
#
# Usage:
#   scripts/install-yt-dlp.sh
#
# Installation Method:
#   APT (pipx, ffmpeg) + pipx (yt-dlp)
#

# Load common functions and error handling
source "$(dirname "$0")/lib/common.sh"

# ============================================================================
# Configuration
# ============================================================================

PACKAGE_NAME="yt-dlp"
APT_DEPENDENCIES=(pipx ffmpeg)

# ============================================================================
# Pre-flight Checks
# ============================================================================

print_header "Installing $PACKAGE_NAME"

require_non_root

# ============================================================================
# Installation
# ============================================================================

for package in "${APT_DEPENDENCIES[@]}"; do
    if ! is_package_installed "$package"; then
        log_step "Installing $package via APT..."
        sudo apt-get install -y "$package"
    fi
done

if pipx list --short | grep -q "^$PACKAGE_NAME "; then
    log_step "Upgrading $PACKAGE_NAME via pipx..."
    pipx upgrade "$PACKAGE_NAME"
else
    log_step "Installing $PACKAGE_NAME via pipx..."
    pipx install "$PACKAGE_NAME"
fi

pipx ensurepath

# ============================================================================
# Post-Installation
# ============================================================================

YT_DLP="$HOME/.local/bin/yt-dlp"

if [ -x "$YT_DLP" ]; then
    log_success "$PACKAGE_NAME installed successfully"

    record_version "$PACKAGE_NAME" "$YT_DLP --version"

    log_info "Installed version: $("$YT_DLP" --version)"

    echo
    log_info "Example (audio only, mp3):"
    log_info "  yt-dlp -x --audio-format mp3 --audio-quality 0 -o '%(title)s.%(ext)s' URL"
    log_info "Upgrade if downloads fail: pipx upgrade yt-dlp  (or re-run make yt-dlp)"
else
    log_error "$PACKAGE_NAME installation failed"
    log_info "Check the log file: $LOG_FILE"
    exit 1
fi

print_separator
