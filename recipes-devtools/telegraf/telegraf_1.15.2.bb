SUMMARY = "The plugin-driven server agent for collecting & reporting metrics."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI = "\
    https://dl.influxdata.com/telegraf/releases/telegraf-${PV}_linux_arm64.tar.gz;name=arm64 \
    file://telegraf.conf \
"
SRC_URI[arm64.sha256sum] = "29ed2c492c0305b70a9f2cd4ad677a7f38717492272f8cc28767f9cb96ca7283"

COMPATIBLE_HOST = "aarch64-poky-linux"

S = "${WORKDIR}/telegraf-${PV}/"

inherit bin_package distro_features_check systemd
REQUIRED_DISTRO_FEATURES = "systemd"

do_install_append() {
    install -d ${D}${systemd_system_unitdir}
    sed -e '/User=telegraf/d; /\[Unit\]/aConditionPathExists=/etc/telegraf/telegraf.conf' <${D}/usr/lib/telegraf/scripts/telegraf.service >${D}${systemd_system_unitdir}/telegraf.service
    rm -r ${D}/var ${D}/etc/logrotate.d ${D}/usr/lib/telegraf \
          ${D}/etc/telegraf/telegraf.conf
    install ${WORKDIR}/telegraf.conf ${D}/etc/telegraf/telegraf.conf
}

INSANE_SKIP_${PN} = "already-stripped"

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE_${PN} = "${PN}.service"
SYSTEMD_AUTO_ENABLE = "enable"