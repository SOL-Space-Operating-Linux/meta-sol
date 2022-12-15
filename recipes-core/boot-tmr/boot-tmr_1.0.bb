SUMMARY = "Just a quick c program to do majority voting in init-boot.sh"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS_prepend := "${THISDIR}/boot-tmr:"
SRC_URI += "file://boot-tmr.c"

S = "${WORKDIR}"

do_compile() {
	bbdebug 1 "hello world ${SRC_URI}"
    ${CC} boot-tmr.c -o boot-tmr
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 boot-tmr ${D}${bindir}
}

INSANE_SKIP_${PN} = "ldflags"

