#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "Error: must be run as root (use sudo)." >&2
	exit 1
fi

set -e # stop in case of error

CONF=etc/default
UNIT=etc/systemd/system
BINR=usr/local/bin
EXE=./rootfs/$BINR/backupd_daemon_exe

rm -f /$CONF/backupd.conf
rm -f /$UNIT/backupd.service /$UNIT/backupd.timer
rm -f /$BINR/backupd /$BINR/backupd_daemon_exe
rm -f "$EXE"

mkdir -p /$CONF /$UNIT /$BINR
g++ -std=c++17 code/backupd_daemon_exe.cpp -o $EXE
chmod 755 $EXE

cp -f ./rootfs/$CONF/backupd.conf /$CONF/
cp -f ./rootfs/$UNIT/backupd.service /$UNIT/
cp -f ./rootfs/$UNIT/backupd.timer /$UNIT/
cp -f ./rootfs/$BINR/backupd /$BINR/
cp -f ./rootfs/$BINR/backupd_daemon_exe /$BINR/

# config 0640
SVC_USER="${SUDO_USER:-root}"
chown root:"$SVC_USER" /$CONF/backupd.conf || true
chmod 0640 /$CONF/backupd.conf

# binaries 0755
chown root:root /$BINR/backupd /$BINR/backupd_daemon_exe || true
chmod 0755 /$BINR/backupd /$BINR/backupd_daemon_exe

systemctl daemon-reload
systemctl disable --now backupd.timer

systemctl status backupd.timer || true
echo "backupd installed"
