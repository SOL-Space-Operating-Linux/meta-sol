SUMMARY = "The plugin-driven server agent for collecting & reporting metrics."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI = "\
    file://host_setup.sh \
    file://enviro_test_short.bash \
    file://enviro_test_long.bash \
    file://set_db_flag.sh"

S = "${WORKDIR}"


COMPATIBLE_HOST = "aarch64-poky-linux"

inherit bin_package

do_install() {
    install -d ${D}/usr/bin/
    install -m 0755 ${WORKDIR}/host_setup.sh ${D}/usr/bin/
    install -m 0755 ${WORKDIR}/enviro_test_short.bash ${D}/usr/bin/
    install -m 0755 ${WORKDIR}/enviro_test_long.bash ${D}/usr/bin/
    install -m 0755 ${WORKDIR}/set_db_flag.sh ${D}/usr/bin/
}

RDEPENDS_${PN} += " \
    bash \
    e2fsprogs \
    memtester \
    stress-ng \
    rt-tests \
"

INSANE_SKIP_${PN} = "already-stripped"