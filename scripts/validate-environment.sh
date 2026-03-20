#!/usr/bin/env bash
#
# validate-environment.sh - Validate installation environment
#
# Description:
#   Checks that the system is ready for installations and validates
#   that required base packages are available.
#
# Usage:
#   scripts/utils/validate-environment.sh

source "$(dirname "$0")/lib/common.sh"

print_header "Validating Installation Environment"

ERRORS=0
WARNINGS=0

# ============================================================================
# System Checks
# ============================================================================

log_step "Checking system information..."

# Check OS
if [ -f /etc/os-release ]; then
    source /etc/os-release
    log_info "OS: $NAME $VERSION"

    if [[ "$VERSION_ID" < "24.04" ]]; then
        log_warn "This project is designed for Ubuntu 24.04 or above, you have $VERSION_ID"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    log_error "Cannot determine OS version"
    ERRORS=$((ERRORS + 1))
fi

# Check architecture
ARCH=$(uname -m)
log_info "Architecture: $ARCH"
if [[ "$ARCH" != "x86_64" ]]; then
    log_warn "Some installations may not support architecture: $ARCH"
    WARNINGS=$((WARNINGS + 1))
fi

# Check if running in VM
if systemd-detect-virt -q; then
    VM_TYPE=$(systemd-detect-virt)
    log_info "Running in VM: $VM_TYPE"
else
    log_info "Running on physical hardware"
fi

# ============================================================================
# Privileges Check
# ============================================================================

log_step "Checking user privileges..."

if [ "$EUID" -eq 0 ]; then
    log_warn "Running as root - most targets should use 'make <target>' not 'sudo make <target>'"
    WARNINGS=$((WARNINGS + 1))
else
    log_info "Running as user: $(whoami)"
fi

# Check sudo access
if sudo -n true 2>/dev/null; then
    log_info "Passwordless sudo: enabled"
else
    if sudo -v; then
        log_info "Sudo access: available (password required)"
    else
        log_error "No sudo access - required for most installations"
        ERRORS=$((ERRORS + 1))
    fi
fi

# ============================================================================
# Network Checks
# ============================================================================

log_step "Checking network connectivity..."

# Check internet connectivity
if ping -c 1 8.8.8.8 &> /dev/null; then
    log_info "Internet connectivity: OK"
else
    log_error "No internet connectivity - required for installations"
    ERRORS=$((ERRORS + 1))
fi

# Check DNS
if ping -c 1 google.com &> /dev/null; then
    log_info "DNS resolution: OK"
else
    log_warn "DNS resolution issues detected"
    WARNINGS=$((WARNINGS + 1))
fi

# ============================================================================
# Disk Space Checks
# ============================================================================

log_step "Checking disk space..."

# Check available space in /
ROOT_SPACE=$(df -h / | awk 'NR==2 {print $4}')
log_info "Available space on /: $ROOT_SPACE"

# Check if less than 10GB
ROOT_SPACE_GB=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "$ROOT_SPACE_GB" -lt 10 ]; then
    log_warn "Low disk space on / (less than 10GB available)"
    WARNINGS=$((WARNINGS + 1))
fi

# Check home directory space
if [ -d "$HOME" ]; then
    HOME_SPACE=$(df -h "$HOME" | awk 'NR==2 {print $4}')
    log_info "Available space in \$HOME: $HOME_SPACE"
fi

# ============================================================================
# Essential Tools Checks
# ============================================================================

log_step "Checking essential tools..."

ESSENTIAL_TOOLS=(
    "curl"
    "wget"
    "gpg"
    "apt-get"
    "dpkg"
    "make"
)

for tool in "${ESSENTIAL_TOOLS[@]}"; do
    if check_command "$tool"; then
        log_debug "$tool: available"
    else
        log_warn "Missing essential tool: $tool"
        WARNINGS=$((WARNINGS + 1))
    fi
done

# ============================================================================
# Repository Configuration Checks
# ============================================================================

log_step "Checking package repository configuration..."

# Check if apt is locked
if fuser /var/lib/dpkg/lock &> /dev/null || \
   fuser /var/lib/apt/lists/lock &> /dev/null || \
   fuser /var/cache/apt/archives/lock &> /dev/null; then
    log_error "APT is locked - another package manager is running"
    ERRORS=$((ERRORS + 1))
else
    log_info "APT: not locked"
fi

# Check if apt update is needed
LAST_UPDATE=$(stat -c %Y /var/cache/apt/pkgcache.bin 2>/dev/null || echo 0)
CURRENT_TIME=$(date +%s)
TIME_DIFF=$((CURRENT_TIME - LAST_UPDATE))
HOURS_SINCE_UPDATE=$((TIME_DIFF / 3600))

if [ $HOURS_SINCE_UPDATE -gt 24 ]; then
    log_warn "Package lists are outdated (last update: ${HOURS_SINCE_UPDATE}h ago)"
    log_info "Consider running: sudo apt-get update"
    WARNINGS=$((WARNINGS + 1))
else
    log_info "Package lists: up to date"
fi

# ============================================================================
# Project Structure Checks
# ============================================================================

log_step "Checking project structure..."

REQUIRED_DIRS=(
    "scripts"
    "scripts/lib"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        log_debug "Directory exists: $dir"
    else
        log_error "Missing directory: $dir"
        ERRORS=$((ERRORS + 1))
    fi
done

REQUIRED_FILES=(
    "Makefile"
    "scripts/lib/common.sh"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        log_debug "File exists: $file"
    else
        log_error "Missing file: $file"
        ERRORS=$((ERRORS + 1))
    fi
done

# ============================================================================
# Configuration Checks
# ============================================================================

log_step "Checking configuration..."

if [ -f "config/default.conf" ]; then
    log_info "Configuration file: found"
    source config/default.conf
    log_debug "Git user: $GIT_USER_NAME"
    log_debug "Git email: $GIT_USER_EMAIL"
else
    log_warn "Configuration file not found: config/default.conf"
    WARNINGS=$((WARNINGS + 1))
fi

# ============================================================================
# Optional Tools Checks
# ============================================================================

log_step "Checking optional tools..."

OPTIONAL_TOOLS=(
    "git"
    "conda"
    "docker"
    "snap"
)

for tool in "${OPTIONAL_TOOLS[@]}"; do
    if check_command "$tool"; then
        VERSION=$($tool --version 2>&1 | head -n 1)
        log_info "$tool: $VERSION"
    else
        log_debug "$tool: not installed (optional)"
    fi
done

# ============================================================================
# Summary
# ============================================================================

print_separator
echo
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    log_success "✓ All checks passed!"
    log_info "System is ready for installations"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    log_success "✓ No critical errors found"
    log_warn "⚠ Warnings: $WARNINGS"
    log_info "System should work, but review warnings above"
    exit 0
else
    log_error "✗ Errors: $ERRORS, Warnings: $WARNINGS"
    log_error "Please fix errors before proceeding with installations"
    exit 1
fi

