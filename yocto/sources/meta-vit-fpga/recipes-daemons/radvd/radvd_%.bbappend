FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://radvd.conf"

inherit systemd
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

do_install:append() {
    sed -i "s/prefix.*::/prefix ${RA_PREFIX}/" ${D}${sysconfdir}/radvd.conf
}
