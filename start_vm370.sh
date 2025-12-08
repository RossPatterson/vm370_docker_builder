#!/bin/sh
# Start Hercules
mkdir io >/dev/null 2>/dev/null || true
./setup.sh
hercules -f hercules.conf -n -r start_vm370.rc >/dev/null 2>/dev/null
