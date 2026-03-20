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

- `Makefile` — orchestrates all installations; each target has a `# target:` comment for `make help`
- `scripts/` — individual install/config scripts; `install-*.sh` installs, `adj-*.sh` adjusts config, `no*.sh` removes
- `scripts/sfd_ClientesLinux_DEB64_Rev26/` — BCCR digital signature client package (Costa Rica)
- `compendium discussion icons/` — SVG/PNG icons for use with draw.io
- `env.yml` / `scripts/environment.yml` — conda environment definitions for GPU setup

## Adding a New Script/Target

1. Create `scripts/install-<name>.sh` following existing script conventions
2. Add a Makefile target with a `# target: <name> - description` comment line above it
3. Specify dependencies as prerequisite targets if needed (e.g., `<name>: java mamba`)
