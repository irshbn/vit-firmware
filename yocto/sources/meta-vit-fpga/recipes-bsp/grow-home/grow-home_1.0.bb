SUMMARY = "Grow home partition service"
DESCRIPTION = "On first boot resizes /home partition on SD card to the maximum available capacity"
HOMEPAGE = "https://emlogic.no/2025/11/grow-your-home-with-yocto/"
BUGTRACKER = "mailto:info@emlogic.no"
SECTION = "bsp/sd-card"
CVE_PRODUCT = "${BPN}"
LICENSE = "CLOSED"

SRC_URI = "file://grow-home.service \
           file://grow-home.sh \
"

FILES:${PN} += "${systemd_system_unitdir}/grow-home.service \
                ${base_sbindir}/grow-home.sh \
"

RDEPENDS:${PN} = "bash e2fsprogs-resize2fs parted util-linux-blkid"

BBCLASSEXTEND = "native"

do_install() {
    install -m 0755 -d ${D}${base_sbindir}/
    install -m 0755 -d ${D}${systemd_system_unitdir}/
    install -m 0755 ${WORKDIR}/grow-home.sh ${D}${base_sbindir}/
    install -m 0644 ${WORKDIR}/grow-home.service ${D}${systemd_system_unitdir}/
}

inherit systemd
SYSTEMD_SERVICE:${PN} = "grow-home.service"
