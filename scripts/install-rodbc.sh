#!/usr/bin/env bash
#
# install-rodbc.sh - Install ODBC drivers required by R
#
# Description:
#   Installs UnixODBC and common database ODBC drivers needed by the R
#   RODBC/DBI/odbc packages to connect to SQL Server, PostgreSQL, MySQL,
#   and SQLite databases.
#
# Requirements:
#   - Ubuntu 24.04
#   - sudo privileges
#
# Usage:
#   sudo scripts/install-rodbc.sh
#
# References:
#   https://db.rstudio.com/best-practices/drivers/#linux-debian-ubuntu
#   http://www.unixodbc.org/odbcinst.html
#   https://db.rstudio.com/odbc/
#
# Installation Method:
#   APT
#

source "$(dirname "$0")/lib/common.sh"

# ============================================================================
# Configuration
# ============================================================================

APT_PACKAGES=(
    unixodbc
    unixodbc-dev
    tdsodbc          # SQL Server (Free TDS)
    odbc-postgresql  # PostgreSQL
    libmyodbc        # MySQL
    libsqliteodbc    # SQLite
)

# ============================================================================
# Pre-flight Checks
# ============================================================================

print_header "Installing ODBC Drivers for R (RODBC)"

require_root

# Check if already installed
if is_package_installed "unixodbc"; then
    log_info "unixodbc is already installed — skipping"
    exit 0
fi

# ============================================================================
# Installation
# ============================================================================

log_step "Installing UnixODBC and common database ODBC drivers..."
ensure_apt_packages "${APT_PACKAGES[@]}"

# ============================================================================
# Post-Installation
# ============================================================================

if is_package_installed "unixodbc"; then
    log_success "ODBC drivers installed successfully"
    record_version "unixodbc" "dpkg -l unixodbc | awk '/^ii/{print \$3}'"
    log_info "Installed drivers:"
    log_info "  - UnixODBC (unixodbc, unixodbc-dev)"
    log_info "  - SQL Server via Free TDS (tdsodbc)"
    log_info "  - PostgreSQL (odbc-postgresql)"
    log_info "  - MySQL (libmyodbc)"
    log_info "  - SQLite (libsqliteodbc)"
    log_info "Configure DSNs in /etc/odbc.ini and /etc/odbcinst.ini"
else
    log_error "ODBC driver installation failed"
    log_info "Check the log file: $LOG_FILE"
    exit 1
fi

print_separator
