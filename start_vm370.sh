#!/bin/sh
# Start Hercules

# Add Hercules to paths
. /usr/local/hercules/setup.sh

mkdir io >/dev/null 2>/dev/null || true
hercules -f hercules.conf -d >/dev/null 2>/dev/null
