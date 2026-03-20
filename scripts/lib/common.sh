#!/usr/bin/env bash

# common.sh - Common shell script library for installation scripts
#
# Usage:
#   source "$(dirname "$0")/lib/common.sh"
#
# This library provides:
#   - Consistent error handling
#   - Colored logging functions
#   - Common utility functions
#   - Root/non-root privilege checks
#   - Package installation helpers

# Exit on any command failure, undefined variable, or pipe failure
set -euo pipefail

# ============================================================================
# Color Codes
# ============================================================================

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# ============================================================================
# Logging Functions
# ============================================================================

# Log directory (create if it doesn't exist)
LOG_DIR="${LOG_DIR:-${HOME}/installations/logs}"
mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_FILE:-${LOG_DIR}/installation-$(date +%Y%m%d).log}"

# Log to file with timestamp
log_to_file() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Info message (green)
log_info() {
    local msg="$*"
    echo -e "${GREEN}[INFO]${NC} $msg"
    log_to_file "INFO: $msg"
}

# Warning message (yellow)
log_warn() {
    local msg="$*"
    echo -e "${YELLOW}[WARN]${NC} $msg"
    log_to_file "WARN: $msg"
}

# Error message (red)
log_error() {
    local msg="$*"
    echo -e "${RED}[ERROR]${NC} $msg" >&2
    log_to_file "ERROR: $msg"
}

# Success message (cyan)
log_success() {
    local msg="$*"
    echo -e "${CYAN}[SUCCESS]${NC} $msg"
    log_to_file "SUCCESS: $msg"
}

# Debug message (magenta) - only shown if DEBUG=1
log_debug() {
    if [ "${DEBUG:-0}" = "1" ]; then
        local msg="$*"
        echo -e "${MAGENTA}[DEBUG]${NC} $msg"
        log_to_file "DEBUG: $msg"
    fi
}

# Step message (blue) - for multi-step processes
log_step() {
    local msg="$*"
    echo -e "${BLUE}[STEP]${NC} $msg"
    log_to_file "STEP: $msg"
}

# ============================================================================
# Privilege Check Functions
# ============================================================================

# Require script to be run as root
require_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root (use sudo)"
        log_info "Usage: sudo $0"
        exit 1
    fi
}

# Require script to NOT be run as root
require_non_root() {
    if [ "$EUID" -eq 0 ]; then
        log_error "This script should NOT be run as root"
        log_info "Usage: $0 (without sudo)"
        exit 1
    fi
}

# ============================================================================
# Command/Package Check Functions
# ============================================================================

# Check if a command is available
check_command() {
    local cmd=$1
    command -v "$cmd" &> /dev/null
}

# Check if already installed (by command)
check_already_installed() {
    local cmd=$1
    if check_command "$cmd"; then
        log_info "$cmd is already installed"
        return 0
    fi
    return 1
}

# Require a command to be available, exit with message if not
require_command() {
    local cmd=$1
    local install_hint=${2:-"Please install $cmd first"}

    if ! check_command "$cmd"; then
        log_error "Required command not found: $cmd"
        log_info "$install_hint"
        exit 1
    fi
}

# Check if a package is installed via dpkg
is_package_installed() {
    local package=$1
    dpkg -l "$package" 2>/dev/null | grep -q "^ii"
}

# ============================================================================
# Package Installation Functions
# ============================================================================

# Ensure an apt package is installed (idempotent)
ensure_apt_package() {
    local package=$1

    if is_package_installed "$package"; then
        log_debug "$package is already installed"
    else
        log_step "Installing $package..."
        apt-get install -y "$package"
        log_success "$package installed"
    fi
}

# Install multiple apt packages
ensure_apt_packages() {
    for package in "$@"; do
        ensure_apt_package "$package"
    done
}

# Add apt repository with GPG key
add_apt_repository() {
    local name=$1
    local key_url=$2
    local repo_line=$3

    log_step "Adding repository: $name"

    # Create keyrings directory if it doesn't exist
    mkdir -p /etc/apt/keyrings

    # Download and add GPG key
    log_debug "Downloading GPG key from $key_url"
    curl -fsSL "$key_url" | gpg --dearmor -o "/etc/apt/keyrings/${name}.gpg"

    # Add repository
    log_debug "Adding repository line: $repo_line"
    echo "$repo_line" | tee "/etc/apt/sources.list.d/${name}.list" > /dev/null

    # Update package lists
    log_step "Updating package lists..."
    apt-get update

    log_success "Repository $name added successfully"
}

# Check if snap package is installed
is_snap_installed() {
    local package=$1
    snap list "$package" &> /dev/null
}

# Install snap package (idempotent)
ensure_snap_package() {
    local package=$1
    local flags=${2:-}

    if is_snap_installed "$package"; then
        log_debug "Snap package $package is already installed"
    else
        log_step "Installing snap package: $package"
        snap install $flags "$package"
        log_success "Snap package $package installed"
    fi
}

# ============================================================================
# File/Download Functions
# ============================================================================

# Download file if it doesn't exist
download_if_missing() {
    local url=$1
    local filename=${2:-$(basename "$url")}

    if [ -f "$filename" ]; then
        log_debug "File already exists: $filename"
    else
        log_step "Downloading $filename..."
        wget -q "$url" -O "$filename"
        log_success "Downloaded $filename"
    fi
}

# Clean up downloaded file
cleanup_file() {
    local filename=$1
    if [ -f "$filename" ]; then
        log_debug "Cleaning up: $filename"
        rm -f "$filename"
    fi
}

# ============================================================================
# Conda/Mamba Functions
# ============================================================================

# Check if conda environment exists
conda_env_exists() {
    local env_name=$1
    conda env list | grep -q "^${env_name} "
}

# Check if package is installed in conda environment
conda_package_installed() {
    local package=$1
    local env_name=${2:-base}

    conda list -n "$env_name" | grep -q "^${package} "
}

# ============================================================================
# Validation Functions
# ============================================================================

# Record installed version in manifest
record_version() {
    local package=$1
    local version_cmd=${2:-"$package --version"}
    local manifest="${HOME}/installations/manifest.txt"

    mkdir -p "$(dirname "$manifest")"

    # Get version
    local version_output
    if version_output=$(eval "$version_cmd" 2>&1 | head -n 1); then
        echo "$package: $version_output" >> "$manifest"
        log_debug "Recorded version: $package: $version_output"
    else
        log_warn "Could not determine version for $package"
    fi
}

# ============================================================================
# Utility Functions
# ============================================================================

# Enable debug mode if DEBUG environment variable is set
if [ "${DEBUG:-0}" = "1" ]; then
    set -x
    log_debug "Debug mode enabled"
fi

# Print a separator line
print_separator() {
    echo "=========================================="
}

# Print a header
print_header() {
    local title="$*"
    echo
    print_separator
    echo "$title"
    print_separator
    echo
}

# Ask yes/no question (returns 0 for yes, 1 for no)
ask_yes_no() {
    local question=$1
    local default=${2:-no}

    if [ "$default" = "yes" ]; then
        local prompt="[Y/n]"
        local default_answer="y"
    else
        local prompt="[y/N]"
        local default_answer="n"
    fi

    read -r -p "$question $prompt " answer
    answer=${answer:-$default_answer}

    case "$answer" in
        [Yy]* ) return 0 ;;
        [Nn]* ) return 1 ;;
        * ) return 1 ;;
    esac
}

# ============================================================================
# Initialization
# ============================================================================

log_debug "Common library loaded"

