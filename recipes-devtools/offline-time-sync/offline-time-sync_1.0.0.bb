SUMMARY = "The plugin-driven server agent for collecting & reporting metrics."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI = "\
    file://sync_time.bash"

S = "${WORKDIR}"


COMPATIBLE_HOST = "aarch64-poky-linux"

inherit bin_package

do_install() {
    install -d ${D}/usr/bin/
    install -m 0755 ${WORKDIR}/sync_time.bash ${D}/usr/bin/
}

RDEPENDS_${PN} += " \
    bash \
"