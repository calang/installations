#!/usr/bin/env bash

# set docker-desktop service pre- and post-execution scripts

echo This has NOT been found to work!
exit 1


# exit on any command failure 
# or usage of undefined variable 
# or failure of any command within a pipaline
set -euo pipefail


# uncomment these lines if you need to ensudre this runs under root/sudo
if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit 1
fi

set -x


# ref: https://www.perplexity.ai/search/take-the-role-of-an-ubuntu-24-kQ1ynodxSbquiUrmiKGn8A
# ref: https://www.digitalocean.com/community/tutorials/understanding-systemd-units-and-unit-files

echo '
[Unit]
Description=Docker Desktop
After=network.target

[Service]
Type=simple
User=calang
ExecStartPre=/home/calang/bin/dd-pre
ExecStart=/opt/docker-desktop/bin/docker-desktop
ExecStop=/home/calang/bin/dd-post

[Install]
WantedBy=multi-user.target
' >/etc/systemd/system/docker-desktop.service

echo Reload the systemd manager to recognize the changes 
systemctl daemon-reload


# To verify that your scripts are being executed, you can add logging to your scripts and check the journal:
# journalctl --user -u docker-desktop
