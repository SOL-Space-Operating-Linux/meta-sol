DESCRIPTION = "MOCI Startup Scripts"
HOMEPAGE = "https://gitlab.smallsat.uga.edu/"
LICENSE = "CLOSED"

FILES_${PN} += "file://init"


do_install() {
    install -d ${D}/etc
    install -d ${D}/etc/init.d
    install -d ${D}/etc/rcS.d
    install -m 0755 ${THISDIR}/files/init ${D}/etc/init.d/moci-startup
    ln -sf ../init.d/moci-startup ${D}/etc/rcS.d/S90moci-startup
}

RDEPENDS_${PN} += "bash"

