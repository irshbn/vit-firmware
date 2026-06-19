SUMMARY = "Simple udhcpd-server application"
DESCRIPTION = "Minimalist DHCP server run as a systemd unit"
HOMEPAGE = "https://github.com/armcc/udhcp"
BUGTRACKER = "https://github.com/armcc/udhcp/issues"
SECTION = "bsp/daemons"
LICENSE = "MIT"
CVE_PRODUCT = "${BPN}"

SRC_URI = "file://udhcpd.service \
           file://udhcpd.conf \
"

inherit systemd
SYSTEMD_SERVICE:${PN} = "udhcpd.service"

do_install() {
        install -d ${D}${systemd_system_unitdir}
        install -m 0644 ${WORKDIR}/udhcpd.service ${D}${systemd_system_unitdir}
        install -d ${D}${sysconfdir}
        install -m 0644 ${WORKDIR}/udhcpd.conf ${D}${sysconfdir}/udhcpd.conf
}

FILES:${PN} += "${systemd_system_unitdir}/udhcpd.service \
                ${sysconfdir}/udhcpd.conf \
"
CONFFILES:${PN} += "${sysconfdir}/udhcpd.conf"

RDEPENDS:${PN} += "bash"

BBCLASSEXTEND = "native"
