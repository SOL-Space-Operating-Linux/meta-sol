SUMMARY = "This is a power monitor python script to grab power readings from the ina3221 chip on the NVIDIA Jetson TX2i SOM"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI = "file://tegra-pwrmon.py \
           file://tegra-pwrmon.service"

COMPATIBLE_HOST = "aarch64-poky-linux"

inherit bin_package distro_features_check systemd
REQUIRED_DISTRO_FEATURES = "systemd"

do_install() {
    install -d ${D}/usr/bin/
    install -d ${D}${systemd_system_unitdir}
    install -m 0755 ${WORKDIR}/tegra-pwrmon.py ${D}/usr/bin/tegra-pwrmon.py
    install ${WORKDIR}/tegra-pwrmon.service ${D}${systemd_system_unitdir}/tegra-pwrmon.service
}

RDEPENDS_${PN} += " \
    python3 \
    python3-pyserial \  
    python3-requests \
"

INSANE_SKIP_${PN} = "already-stripped"

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE_${PN} = "${PN}.service"
SYSTEMD_AUTO_ENABLE = "enable"