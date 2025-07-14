#!/bin/sh
# Make Hercules Docker Distribution

# Exit if there is an error
set -e

# Show the commands
set -x

# HercControl
wget -nv https://github.com/adesutherland/HercControl/releases/download/v1.1.0/HercControl-Ubuntu.zip
unzip HercControl-Ubuntu.zip
chmod +x HercControl-Ubuntu/herccontrol
mv HercControl-Ubuntu/herccontrol /usr/local/bin
rm -r HercControl-Ubuntu
rm HercControl-Ubuntu.zip

# Remove Shadow Files
mkdir -p ./disks/shadows # Hercules won't run sf- if the shadow dir doesn't exist.
hercules -f cleandisks.conf -d >/dev/null 2>/dev/null &
herccontrol "sf-* force" -w "HHCCD092I"
herccontrol "exit"

# Move Disks
mv ./disks/*.cckd .

# Start Hercules
(cd /opt/hercules/vm370; hercules -f hercules.conf -d >/dev/null 2>/dev/null &)

# YATA UBUNTU
wget -nv https://github.com/rosspatterson/yata/releases/download/v1.2.8/YATA-Ubuntu.zip
unzip YATA-Ubuntu.zip
chmod +x YATA-Ubuntu/yata
mv YATA-Ubuntu/yata /usr/local/bin
rm -r YATA-Ubuntu
rm YATA-Ubuntu.zip

# YATA CMS
wget -nv https://github.com/rosspatterson/yata/releases/download/v1.2.8/YATA-CMS.zip
unzip YATA-CMS.zip
mkdir io
mv YATA-CMS/yatabin.aws io
rm -r YATA-CMS
rm YATA-CMS.zip

# IPL
herccontrol "ipl 6a1" -w "USER DSC LOGOFF AS AUTOLOG1"

# LOGON MAINTC AND READ TAPE
herccontrol "/cp disc" -w "^VM/370 Online"
herccontrol "/logon maintc maintc" -w "^VM Community Edition V1 R1.2"
herccontrol "/access (noprof" -w "^Ready;"
herccontrol "/profile" -w "^Ready;"
herccontrol "devinit 480 io/yatabin.aws" -w "^HHCPN098I"
herccontrol "/cp disc" -w "^VM/370 Online"
herccontrol "/logon operator operator" -w "RECONNECTED AT"
herccontrol "/attach 480 to maintc as 181" -w "TAPE 480 ATTACH TO MAINT"
herccontrol "/cp disc" -w "^VM/370 Online"
herccontrol "/logon maintc maintc" -w "RECONNECTED"
herccontrol "/begin"
herccontrol "/tape load * * t" -w "^Ready;"
herccontrol "/detach 181" -w "^Ready;"
herccontrol "/yata -v" -w "^Ready;"
herccontrol "/logoff" -w "^VM/370 Online"

# REBUILD CMS
herccontrol "/logon maint cpcms" -w "^VM Community Edition V1 R1.2"
herccontrol "/access (noprof" -w "^Ready;"
herccontrol "/profile" -w "^Ready;"
herccontrol "/NEWBREXX" -w "^Ready"
herccontrol "/define storage 16m"  -w "CP ENTERED"
herccontrol "/ipl 190 clear" -w "^VM Community Edition V1 R1.2"
herccontrol "/savesys cms" -w "^VM Community Edition V1 R1.2"
herccontrol "/" -w "^Ready;"
herccontrol "/logoff" -w "^VM/370 Online"

# SHUTDOWN
herccontrol "/logon operator operator" -w "RECONNECTED AT"
herccontrol "/shutdown" -w "^HHCCP011I"

# Remove temp YATA download
rm -r io

herccontrol "exit"
