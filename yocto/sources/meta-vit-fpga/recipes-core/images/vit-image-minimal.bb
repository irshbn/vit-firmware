require recipes-core/images/petalinux-image-minimal.bb
IMAGE_INSTALL:append = " grow-home radvd"
WKS_FILES = "grow-home.wks"
