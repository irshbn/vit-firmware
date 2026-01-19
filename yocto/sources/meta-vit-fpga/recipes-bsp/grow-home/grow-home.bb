DESCRIPTION = "Grow home partition service"
LICENSE = "CLOSED"
SRC_URI = "file://grow-home.service \
           file://grow-home.sh \
"
S = "${WORKDIR}"
RDEPENDS:${PN} += "bash parted e2fsprogs-resize2fs util-linux-blkid"
do_install() {
    install -m 0755 -d ${D}${base_sbindir}/
    install -m 0755 -d ${D}${systemd_system_unitdir}/
    install -m 0755 ${WORKDIR}/grow-home.sh ${D}${base_sbindir}/
    install -m 0644 ${WORKDIR}/grow-home.service ${D}${systemd_system_unitdir}/
}
FILES:${PN} = " \
    ${systemd_system_unitdir}/grow-home.service \
    ${base_sbindir}/grow-home.sh \
"
inherit systemd
SYSTEMD_SERVICE:${PN} = "grow-home.service"
