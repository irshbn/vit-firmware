# Local parameters
WORKDIR=work
XILBRANCH=rel-v2024.2

# Initialize xilinx-yocto repo of branch XILBRANCH in WORKDIR 
cd $WORKDIR || exit
repo init -u https://github.com/Xilinx/yocto-manifests.git -b $XILBRANCH
repo sync
