DESCRIPTION = "TX2i API"
HOMEPAGE = "http://gitlab.smallsat.uga.edu/"
LICENSE = "CLOSED"

S = "${WORKDIR}/git"

SRC_URI = "git://gitlab.smallsat.uga.edu/flight-software/moci-software/tx2-controller.git;protocol=https;branch=c++"
SRCREV = "c0e39e247edb8b6753dfe00409ef271798440142"

inherit pkgconfig cmake

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/bin/API ${D}${bindir}
}

