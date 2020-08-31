SUMMARY = "The plugin-driven server agent for collecting & reporting metrics."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI = "\
    file://sync_time.bash \
    file://offline-time-sync.service"

S = "${WORKDIR}"


COMPATIBLE_HOST = "aarch64-poky-linux"

inherit bin_package distro_features_check systemd
REQUIRED_DISTRO_FEATURES = "systemd"

do_install() {
    install -d ${D}${systemd_system_unitdir}
    install -d ${D}/usr/bin/
    install -m 0755 ${WORKDIR}/sync_time.bash ${D}/usr/bin/
    install ${WORKDIR}/offline-time-sync.service ${D}${systemd_system_unitdir}/offline-time-sync.service
}

RDEPENDS_${PN} += " \
    bash \
"

INSANE_SKIP_${PN} = "already-stripped"

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE_${PN} = "${PN}.service"
SYSTEMD_AUTO_ENABLE = "enable"