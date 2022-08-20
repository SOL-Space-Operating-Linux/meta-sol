SUMMARY = "This is a power monitor python script to grab power readings from the ina3221 chip on the NVIDIA Jetson TX2i SOM"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI = "file://tegra-pwrmon.py"

COMPATIBLE_HOST = "aarch64-poky-linux"

inherit bin_package

do_install() {
    install -d ${D}/usr/bin/
    install -m 0755 ${WORKDIR}/tegra-pwrmon.py ${D}/usr/bin/tegra-pwrmon.py
}

RDEPENDS_${PN} += " \
    python3 \
    python3-pyserial \  
    python3-requests \
"