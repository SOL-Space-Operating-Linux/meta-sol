SUMMARY = "SOL development applications" 
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
    go-runtime \
    telegraf \
    stress-ng \
    rt-tests \
    memtester \
    tegra-pwrmon \
    lmsensors-libsensors \
    lmsensors-sensord \
    lmsensors-sensors \
    lmsensors-sensorsconfconvert \
    lmsensors-sensorsdetect \
"