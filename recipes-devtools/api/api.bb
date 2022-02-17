DESCRIPTION = "TX2i API"
HOMEPAGE = "http://gitlab.smallsat.uga.edu/"
LICENSE = "CLOSED"

SRC_URI = "file://tx2-controller.tar"

S = "${WORKDIR}/tx2-controller"

inherit pkgconfig cmake

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/bin/API ${D}${bindir}
}

