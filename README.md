# Ubuntu installations

This repository is a collection of shell scripts and a Makefile to automate the setup of an Ubuntu workstation (Dell XPS). It manages installation and configuration of development tools, languages, and applications.

Read [CLAUDE.md](.claude/CLAUDE.md) for guidance on how to use this repository effectively, including conventions and best practices for running the scripts and understanding the Makefile targets.

## Basic setup

### BIOS To Recover Wndows 11

- Factory setting +
- BIOS: Secure Boot, Enable MS UEFI CA
- Stor: RAID on, Smart Reporting Off
- Security: Disable Absolute
- Keyboard: Fn lockMode: On, Lock mode secondary

### BIOS set-up for Ubuntu 24.04

- Power-on + F2
- BIOS: UEFI
- Disable Absolute
- Storage: SATA: AHCI
- Boot Config: Secure Boot: Disable

1. Install from USB drive
2. Settings > Software Update
    - restart

**Re**: How to Install Ubuntu Linux on your Dell Computer.

**Note**: To remove BitLocker, format the partition.

### Recover Backup
From G-Drive, calang-xps.

## Run rest of installations
As configured via the Makefile

### Pending
- enable camera
    - https://github.com/intel/ipu6-drivers/issues/228
    - how to test: sudo apt-get install -y cheese
- enable sound card (speakers, microphone)
    - https://bugs.launchpad.net/ubuntu/+source/firmware-sof/+bug/2058691/comments/6
    - https://github.com/thesofproject/linux/issues/4879


