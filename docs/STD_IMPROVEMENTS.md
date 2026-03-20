# Project Simplification and Standardization Improvements

## Analysis Date: March 20, 2026

This document outlines recommended improvements for the Ubuntu installations project to increase consistency, maintainability, and ease of use.

---

## 1. Script Header Standardization

### Current Issue
- **Inconsistent shebangs**: Most scripts use `#!/usr/bin/env bash`, but some use `#!/bin/bash`
  - Files using `#!/bin/bash`: `install-antigravity.sh`, `Xinstall.sh`
- **Inconsistent spacing** in comments across scripts
- **Redundant comments** like "uncomment these lines if you need to ensure this runs under root/sudo"

### Recommendation
Create a **common script template/library** file: `scripts/lib/common.sh`

```bash
#!/usr/bin/env bash

# Common shell script library for installation scripts
# Source this at the beginning of each script

# Exit on any command failure, undefined variable, or pipe failure
set -euo pipefail

# Enable trace output (can be overridden by individual scripts)
# set -x

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Common functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

require_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

require_non_root() {
    if [ "$EUID" -eq 0 ]; then
        log_error "This script should NOT be run as root"
        exit 1
    fi
}

check_already_installed() {
    local cmd=$1
    if command -v "$cmd" &> /dev/null; then
        log_info "$cmd is already installed"
        return 0
    fi
    return 1
}

ensure_package() {
    local package=$1
    if dpkg -l "$package" 2>/dev/null | grep -q "^ii"; then
        log_info "$package is already installed"
    else
        log_info "Installing $package..."
        apt-get install -y "$package"
    fi
}
```

**Action**: Update all scripts to source this common library and use standardized functions.

---

## 2. Makefile Improvements

### Current Issues
- **Inconsistent target definitions**: Some targets have comments above, some inline
- **Duplicate commented-out code** (clasp, clingo)
- **Long "Pending" list** that could be in a separate tracking file
- **Inconsistent spacing** between targets

### Recommendations

#### A. Organize targets by category with clear sections
```makefile
# === PACKAGE INSTALLATION ===

## Development Tools
# target: git - Install git, gitk, git-gui
git:
	sudo scripts/install-git.sh

## Editors & IDEs
# target: vscode - Install VS Code
vscode:
	sudo scripts/install-vscode.sh

## Container & Virtualization
# target: docker-ce - Install Docker Community Edition
docker-ce:
	sudo scripts/install-docker-ce.sh
```

#### B. Move pending items to `TODO.md`
Create a separate file to track future installations rather than cluttering the Makefile.

#### C. Remove or move commented code
- Move commented-out targets to `ARCHIVE.md` with reasons why they're disabled
- Keep Makefile clean and active

#### D. Add validation targets
```makefile
# target: validate - Check if all required tools are available
validate:
	@echo "Validating installation environment..."
	@scripts/validate-environment.sh

# target: check - Run basic health checks on installed packages
check:
	@scripts/check-installations.sh
```

---

## 3. Script Organization

### Current Issues
- Mix of install, adjust, and removal scripts in same directory
- No clear naming convention for parameter requirements
- `Xinstall.sh` and `Xtest_tensorflow.py` have unclear naming (X prefix)

### Recommendations

#### A. Reorganize scripts into subdirectories
```
scripts/
├── lib/
│   ├── common.sh          # Common functions
│   └── ensure_apt.sh      # APT-specific helpers
├── install/
│   ├── git.sh
│   ├── docker-ce.sh
│   ├── mamba.sh
│   └── ...
├── config/
│   ├── git.sh             # Previously adj-git.sh
│   ├── prompt.sh          # Previously adj-prompt.sh
│   └── ...
├── remove/
│   ├── thunderbird.sh     # Previously nothunderbird.sh
│   └── docker-desk.sh     # Previously nodocker-desk.sh
├── utils/
│   ├── run-all.sh
│   ├── check-nvidia.py
│   └── validate-environment.sh
└── archived/
    ├── install-clasp.sh   # Non-working installations
    └── test_tensorflow.py
```

#### B. Update Makefile to reference new paths
```makefile
git:
	sudo scripts/install/git.sh

git-user:
	scripts/config/git.sh
```

---

## 4. Idempotency and Checks

### Current Issues
- **Inconsistent idempotency checks**: Some scripts check if already installed, others don't
- **Different check methods**: `which`, `command -v`, `apt list`, `conda list`, etc.
- Some scripts like `install-chrome.sh` leave downloaded files behind

### Recommendations

#### A. Standardize "already installed" checks in common library
Use the `check_already_installed` function from the common library.

#### B. Create script template
```bash
#!/usr/bin/env bash
source "$(dirname "$0")/lib/common.sh"

# Brief description of what this script does
PACKAGE_NAME="example"

require_root  # or require_non_root if appropriate

# Check if already installed
if check_already_installed "$PACKAGE_NAME"; then
    exit 0
fi

log_info "Installing $PACKAGE_NAME..."

# Installation logic here

# Cleanup temporary files
# ...

log_info "$PACKAGE_NAME installed successfully"
```

#### C. Add cleanup steps
Ensure all scripts clean up temporary files (`.deb`, `.sh`, `.gpg`, etc.) after installation.

---

## 5. Documentation Improvements

### Current Issues
- Installation instructions scattered across `README.md`, `CLAUDE.md`, and comments
- No clear guide for adding new installations
- No troubleshooting section

### Recommendations

#### A. Create comprehensive documentation structure
```
docs/
├── GETTING_STARTED.md     # Quick start guide
├── ADDING_SCRIPTS.md      # Template and guide for adding new installations
├── TROUBLESHOOTING.md     # Common issues and solutions
└── ARCHITECTURE.md        # Project structure and design decisions
```

#### B. Enhance README.md
- Add a clear table of contents
- Link to specific documentation
- Add quick examples
- Include prerequisites

#### C. Add inline documentation
Use consistent comment headers in all scripts:
```bash
#!/usr/bin/env bash
#
# install-example.sh - Install Example Package
#
# Description:
#   This script installs the Example package from the official repository.
#
# Requirements:
#   - Ubuntu 24.04
#   - sudo privileges
#   - Internet connection
#
# Usage:
#   sudo ./install-example.sh
#
```

---

## 6. Error Handling and Logging

### Current Issues
- Minimal error messages
- No logging to files for debugging
- `set -x` traces everything (very verbose)

### Recommendations

#### A. Implement structured logging
```bash
# In common.sh
LOG_FILE="${LOG_FILE:-/var/log/ubuntu-installations.log}"

log_to_file() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

log_info() {
    local msg="$*"
    echo -e "${GREEN}[INFO]${NC} $msg"
    log_to_file "INFO: $msg"
}
```

#### B. Add debug mode
```bash
# Enable with: DEBUG=1 make git
if [ "${DEBUG:-0}" = "1" ]; then
    set -x
fi
```

#### C. Add failure recovery hints
When operations fail, provide actionable suggestions:
```bash
if ! apt-get install -y example; then
    log_error "Failed to install example"
    log_info "Try running: sudo apt-get update && sudo apt-get install -f"
    exit 1
fi
```

---

## 7. Dependency Management

### Current Issues
- Dependencies specified in Makefile but not validated
- No clear dependency tree visualization
- Some scripts assume others have run (e.g., `ensure_apt.sh` must be sourced)

### Recommendations

#### A. Add dependency validation script
```bash
#!/usr/bin/env bash
# scripts/utils/check-dependencies.sh

check_dependency() {
    local dep=$1
    if ! command -v "$dep" &> /dev/null; then
        echo "Missing dependency: $dep"
        echo "  Install with: make $(get_target_for_command "$dep")"
        return 1
    fi
    return 0
}
```

#### B. Create dependency graph generator
```bash
# Generate a visual dependency tree
make deps-graph
# Outputs: dependencies.dot (can be viewed with xdot or converted to PNG)
```

#### C. Add pre-flight checks to scripts
```bash
# At the start of install-jupl.sh
require_command conda "Please install mamba first: make mamba"
```

---

## 8. Testing and Validation

### Current Issues
- No automated testing
- No way to verify installations succeeded
- `run-all.sh` doesn't report which installations failed

### Recommendations

#### A. Add post-installation validation
Each installation script should have a corresponding validation:
```bash
# scripts/validate/git.sh
#!/usr/bin/env bash
source "$(dirname "$0")/lib/common.sh"

if command -v git &> /dev/null; then
    log_info "git: $(git --version)"
    exit 0
else
    log_error "git validation failed"
    exit 1
fi
```

#### B. Create comprehensive test suite
```makefile
# target: test - Run validation tests on all installed packages
test:
	@scripts/utils/run-tests.sh

# target: test-git - Test git installation
test-git:
	@scripts/validate/git.sh
```

#### C. Improve run-all.sh
```bash
# Track successes and failures
declare -a SUCCEEDED=()
declare -a FAILED=()

for target in $LIST; do
    if make "$target"; then
        SUCCEEDED+=("$target")
    else
        FAILED+=("$target")
    fi
done

# Report summary
echo "===================================="
echo "Installation Summary"
echo "===================================="
echo "Succeeded: ${#SUCCEEDED[@]}"
echo "Failed: ${#FAILED[@]}"
if [ ${#FAILED[@]} -gt 0 ]; then
    echo "Failed targets: ${FAILED[*]}"
fi
```

---

## 9. Configuration Management

### Current Issues
- Hardcoded values (email, username in `adj-git.sh`)
- No central configuration file
- Environment-specific values scattered across scripts

### Recommendations

#### A. Create configuration file
```bash
# config/default.conf
# Ubuntu Installation Configuration

# User settings
GIT_USER_NAME="Carlos A. Lang-Sanou"
GIT_USER_EMAIL="carlos.lang@gmail.com"

# Installation paths
INSTALL_PREFIX="${HOME}/.local"
CONDA_PREFIX="${HOME}/miniforge3"

# GPU settings
GPU_ENV="nvidia_gpu_setup"

# Version pins (optional, for reproducibility)
DOCKER_VERSION="latest"
VSCODE_VERSION="latest"
```

#### B. Source configuration in scripts
```bash
source "$(dirname "$0")/../config/default.conf"
git config --global user.email "$GIT_USER_EMAIL"
```

#### C. Allow environment override
```bash
# Can override with: GIT_USER_EMAIL="other@email.com" make git-user
GIT_USER_EMAIL="${GIT_USER_EMAIL:-carlos.lang@gmail.com}"
```

---

## 10. Package Manager Abstraction

### Current Issues
- Mix of `apt`, `snap`, `wget`, `curl`, manual downloads
- Different patterns for adding repositories
- No consistent approach to package sources

### Recommendations

#### A. Create package manager helpers
```bash
# In common.sh or separate lib/package-managers.sh

install_apt_package() {
    local package=$1
    ensure_package "$package"
}

install_snap_package() {
    local package=$1
    local flags=${2:-}
    if snap list "$package" &> /dev/null; then
        log_info "Snap package $package already installed"
    else
        snap install $flags "$package"
    fi
}

add_apt_repository() {
    local name=$1
    local key_url=$2
    local repo_line=$3
    
    # Standardized repository addition
    mkdir -p /etc/apt/keyrings
    curl -fsSL "$key_url" | gpg --dearmor -o "/etc/apt/keyrings/${name}.gpg"
    echo "$repo_line" | tee "/etc/apt/sources.list.d/${name}.list" > /dev/null
    apt-get update
}
```

#### B. Document installation methods
Add comments to each script indicating the installation method:
```bash
# Installation method: APT package
# Installation method: Direct download + dpkg
# Installation method: Snap
# Installation method: Custom repository
# Installation method: Source build
```

---

## 11. Version Management

### Current Issues
- No version tracking for installed packages
- Hard to reproduce exact environment
- Updates may break compatibility

### Recommendations

#### A. Create version manifest
```bash
# After each installation, record version
echo "git: $(git --version)" >> ~/.ubuntu-installation-manifest.txt
echo "docker: $(docker --version)" >> ~/.ubuntu-installation-manifest.txt
```

#### B. Add version pinning support (optional)
```bash
# In config file
PIN_VERSIONS=false  # Set to true for reproducible builds

if [ "$PIN_VERSIONS" = "true" ]; then
    apt-get install -y "docker-ce=5:24.0.0-1~ubuntu.24.04~noble"
else
    apt-get install -y docker-ce
fi
```

---

## 12. Continuous Improvement

### Recommendations

#### A. Add Makefile target for project maintenance
```makefile
# target: lint - Check all scripts for common issues
lint:
	@shellcheck scripts/**/*.sh

# target: format - Format all scripts consistently
format:
	@shfmt -w -i 4 scripts/**/*.sh

# target: audit - Security audit of installed packages
audit:
	@scripts/utils/security-audit.sh
```

#### B. Create contribution guidelines
`CONTRIBUTING.md` with:
- Script template
- Testing requirements
- Documentation requirements
- Code review process

---

## Priority Implementation Plan

### Phase 1: Foundation (High Priority)
1. ✅ Create `scripts/lib/common.sh` with standard functions
2. ✅ Update shebang inconsistencies (`#!/bin/bash` → `#!/usr/bin/env bash`)
3. ✅ Add logging and better error messages
4. ✅ Create configuration file for hardcoded values

### Phase 2: Organization (Medium Priority)
5. ✅ Reorganize scripts into subdirectories
6. ✅ Update Makefile to use new paths
7. ✅ Create `TODO.md` and `ARCHIVE.md`
8. ✅ Add validation scripts

### Phase 3: Enhancement (Lower Priority)
9. ✅ Improve documentation structure
10. ✅ Add dependency checking
11. ✅ Implement comprehensive testing
12. ✅ Add linting and formatting tools

---

## Quick Wins (Immediate Actions)

These can be done right away with minimal effort:

1. **Standardize shebangs**: Change all `#!/bin/bash` to `#!/usr/bin/env bash`
2. **Clean up Makefile**: Remove commented code, move to ARCHIVE.md
3. **Create TODO.md**: Move pending list from Makefile
4. **Add .gitignore**: Ignore temporary files (*.deb, *.gpg, *.sh downloads)
5. **Document current state**: Add comments to complex scripts
6. **Fix obvious bugs**: 
   - `install-chrome.sh` line 23: `set x` should be `set +x`
   - Cleanup downloaded files after installation

---

## Conclusion

These improvements will make the project:
- **More maintainable**: Consistent structure and patterns
- **More reliable**: Better error handling and validation
- **More usable**: Clear documentation and helpful messages
- **More professional**: Standard practices and tooling

The suggested changes are backward-compatible and can be implemented incrementally without disrupting current workflows.

