DESCRIPTION = "moyoloci"
HOMEPAGE = "https://gitlab.smallsat.uga.edu/jop80923/moyoloci"
LICENSE = "CLOSED"

FILESEXTRAPATHS_prepend := "${THISDIR}:"
SRC_URI = "file://moyoloci.tar.gz"

S = "${WORKDIR}/moyoloci"

INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INSANE_SKIP_${PN} += "already-stripped"
INSANE_SKIP_${PN} += "ldflags"
do_package_qa[noexec] = "1"
EXCLUDE_FROM_SHLIBS = "1"

do_unpack() {
	mkdir ${S}/moyoloci
	tar -C ${S}/moyoloci -x -f ${THISDIR}/moyoloci/moyoloci.tar.gz
	rm -rf ${S}/moyoloci/.git
	rm -rf ${S}/moyoloci/data
}

do_install() {
	install -d ${D}/home/root
	cp -r ${S}/moyoloci ${D}/home/root/moyoloci
}

FILES_${PN} += "/home"
FILES_${PN} += "/home/root"
FILES_${PN} += "/home/root/moyoloci"
