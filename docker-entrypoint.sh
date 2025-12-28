#!/bin/bash
set -e

# Set xilinx-yocto branch here
XILBRANCH=rel-v2024.2

# Switch to workdir and initialise repo if there isn't one
cd work

if ! [ -d ".repo" ]; then
  yes | repo init -u https://github.com/Xilinx/yocto-manifests.git -b $XILBRANCH
  repo sync
fi

# Setup xilinx-yocto SDK env and run user-defined commands
source setupsdk build
exec "$@"
