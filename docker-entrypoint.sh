#!/bin/bash
set -e

# If Xilinx branch is provided and workdir is mounted, run SDK setup
if [[ -n $XIL_BRANCH && -d work ]]; then
  cd work

  if [[ ! -d ".repo" ]]; then
    yes | repo init -u https://github.com/Xilinx/yocto-manifests.git -b "$XIL_BRANCH"
    repo sync
    source setupsdk build
    bitbake-layers add-layer meta-vit-fpga
    echo 'INHERIT += "rm_work"' >>conf/local.conf # Remove workdir artifacts after building by default
  else
    source setupsdk build
  fi
fi

exec "$@"
