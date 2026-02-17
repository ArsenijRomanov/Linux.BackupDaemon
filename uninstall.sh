#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "Error: must be run as root (use sudo)." >&2
	exit 1
fi

set -e

CONF=etc/default
UNIT=etc/systemd/system
BINR=usr/local/bin
EXE=./rootfs/$BINR/backupd_daemon_exe

systemctl disable --now backupd.timer 2>/dev/null || true
systemctl stop backupd.service 2>/dev/null || true

rm -f /$CONF/backupd.conf
rm -f /$UNIT/backupd.service /$UNIT/backupd.timer
rm -rf /$UNIT/backupd.timer.d
rm -f /$BINR/backupd /$BINR/backupd_daemon_exe

rm -f "$EXE"

systemctl daemon-reload
systemctl reset-failed 2>/dev/null || true

echo "backupd removed"
