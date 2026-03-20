# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This repository is a collection of shell scripts and a Makefile to automate the setup of an Ubuntu 24.04 workstation (Dell XPS). It manages installation and configuration of development tools, languages, and applications.

## Running Installations

All installations are driven via `make`. Each target maps to a script in `scripts/`.

```bash
make help              # list all available targets
make <target>          # run a specific installation
scripts/run-all.sh     # run all targets sequentially (reads Makefile for target list)
```

Most `install-*.sh` scripts require `sudo` and are invoked via `sudo scripts/install-*.sh`. Some (like `mamba`, `claude`, `jupl`) run as the current user without sudo.

## Script Conventions

- All scripts begin with `set -euo pipefail` (fail fast on errors, unset vars, pipe failures)
- `set -x` is used for trace output during execution
- Scripts check for root with `$EUID -ne 0` when sudo is required
- `scripts/ensure_apt.sh` provides a reusable `ensure_apt()` function for idempotent package installs
- Some scripts guard against re-installation (e.g., `which conda || scripts/install-mamba.sh`)

## Key Makefile Targets

| Target | Description |
|--------|-------------|
| `git`, `git-user` | Install git/gitk/git-gui and configure user identity |
| `mamba` / `conda` | Install Miniforge (mamba/conda) per-user |
| `jupl` | Install JupyterLab in mamba base env |
| `jupl-swi` | Install SWI-Prolog Jupyter kernel |
| `swi-prolog` | Install SWI-Prolog |
| `docker-ce` / `docker-desk` | Install Docker Engine or Docker Desktop |
| `gpu` / `gpu-env` | Set up NVIDIA GPU environment via conda |
| `gaudi` | Install BCCR digital signature agent (Costa Rica) |
| `zim-xtras` | Install Zim wiki extras (depends on zim, git, graphviz) |

## Repository Structure

- `compendium discussion icons/` — SVG/PNG icons for use with draw.io
- `config/default.conf` - Centralized configuration
- `env.yml` / `scripts/environment.yml` — conda environment definitions for GPU setup
- `Makefile` — orchestrates all installations; each target has a `# target:` comment for `make help`
- `scripts/` — individual install/config scripts; `install-*.sh` installs, `adj-*.sh` adjusts config, `no*.sh` removes
- `scripts/lib/common.sh` - Shared functions library for all scripts
- `scripts/TEMPLATE-install.sh` - Template for new installation scripts
- `scripts/sfd_ClientesLinux_DEB64_Rev26/` — BCCR digital signature client package (Costa Rica)

## How to Use the Common Library

### Basic Pattern
Every script should start with:

```bash
#!/usr/bin/env bash
source "$(dirname "$0")/lib/common.sh"

print_header "Installing My Package"
require_root
```

### Common Functions to Use

| Instead of... | Use this... |
|--------------|-------------|
| `echo "Installing..."` | `log_info "Installing..."` |
| `echo "ERROR: Failed"` | `log_error "Failed"` |
| `if [ "$EUID" -ne 0 ]` | `require_root` |
| `apt install -y pkg` | `ensure_apt_package "pkg"` |
| `if which cmd` | `if check_already_installed "cmd"` |
| `wget https://...` | `download_if_missing "https://..."` |
| `rm file.deb` | `cleanup_file "file.deb"` |

## How to Create a New Installation Script

1. **Copy the template:**
   ```bash
   cp scripts/TEMPLATE-install.sh scripts/install-mynewapp.sh
   ```

2. **Fill in the template:**
   - Update the header comments
   - Set PACKAGE_NAME
   - Choose installation method
   - Remove unused sections

3. **Make it executable:**
   ```bash
   chmod +x scripts/install-mynewapp.sh
   ```

4. **Add to Makefile:**
   ```makefile
   # target: mynewapp - Install My New App
   mynewapp:
       sudo scripts/install-mynewapp.sh
   ```

5. **Test it:**
   ```bash
   make mynewapp
   ```
