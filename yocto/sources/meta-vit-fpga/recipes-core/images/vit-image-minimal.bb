SUMMARY = "Petalinux-based minimal image for ViT-fpga"
DESCRIPTION = "Minimal distro with routing capabilities and SD-card memory expansion"
BUGTRACKER = "https://github.com/irshbn/vit-fpga/issues"
SECTION = "images"
LICENSE = "MIT"
CVE_PRODUCT = "${BPN}"

# nooelint: oelint.file.requirenotfound
require recipes-core/images/petalinux-image-minimal.bb

IMAGE_INSTALL:append = " grow-home radvd udhcpd"
WKS_FILES = "grow-home.wks"
