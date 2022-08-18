DESCRIPTION = "TX2i API"
HOMEPAGE = "http://gitlab.smallsat.uga.edu/"
LICENSE = "CLOSED"

S = "${WORKDIR}/git"

SRC_URI = "git://gitlab.smallsat.uga.edu/flight-software/moci-software/tx2-controller.git;protocol=https;branch=master"
SRCREV = "d3a269c2ae2a6735e6acfe044f011026c000f6d4"

do_install() {
    install -d ${D}/usr/bin
    install -d ${D}/usr/bin/api
    cd ${S}
    find . -not -path '*/\.git/*' -exec install -Dm 755 "{}" "${D}/usr/bin/api/{}" \;
    cd -
}
# look into an alternative to opencv
RDEPENDS_${PN} += " \
    python3 \
    python3-pyserial \
    python3-crcmod \
    python3-opencv \
    ffmpeg \
"