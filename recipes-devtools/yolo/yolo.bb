DESCRIPTION = "Darknet for YOLO"
HOMEPAGE = "https://github.com/pjreddie/darknet.git"
LICENSE = "CLOSED"

SRC_URI = "git://github.com/pjreddie/darknet.git;protocol=https"
SRCREV = "a028bfa0da8eb96583c05d5bd00f4bfb9543f2da"

EXTRA_OEMAKE += "'CC=${CC}' 'CXX=${CXX}'"
S = "${WORKDIR}/git"

INSANE_SKIP_${PN} = "ldflags"

do_compile() {
    oe_runmake darknet
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/darknet ${D}${bindir}
}