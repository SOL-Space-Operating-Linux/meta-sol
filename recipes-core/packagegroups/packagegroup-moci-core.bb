SUMMARY = "MOCI core dependencies" 
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
    tegra-sfm \
    yolo-gpu \
    api \
    moci-startup \
    tar \
    update-rootfs \
    tegra-pwrmon \
    telegraf \
    tegrastats-influx \
    lmsensors-libsensors \
    lmsensors-sensord \
    lmsensors-sensors \
    lmsensors-sensorsconfconvert \
"
