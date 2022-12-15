SUMMARY = "The plugin-driven server agent for collecting & reporting metrics."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI = "\
    file://host_setup.sh \
    file://enviro_test.bash \
    file://tegrastats_influx.sh \
    file://start_logging.sh \
    file://set_db_flag.sh"

S = "${WORKDIR}"


COMPATIBLE_HOST = "aarch64-poky-linux"

inherit bin_package

do_install() {
    install -d ${D}/usr/bin/
    install -m 0755 ${WORKDIR}/host_setup.sh ${D}/usr/bin/
    install -m 0755 ${WORKDIR}/enviro_test.bash ${D}/usr/bin/
    install -m 0755 ${WORKDIR}/tegrastats_influx.sh ${D}/usr/bin/
    install -m 0755 ${WORKDIR}/set_db_flag.sh ${D}/usr/bin/
    install -m 0755 ${WORKDIR}/start_logging.sh ${D}/usr/bin/
}

RDEPENDS_${PN} += " \
    bash \
    e2fsprogs \
    memtester \
    stress-ng \
    rt-tests \
    cuda-samples \
"

INSANE_SKIP_${PN} = "already-stripped"