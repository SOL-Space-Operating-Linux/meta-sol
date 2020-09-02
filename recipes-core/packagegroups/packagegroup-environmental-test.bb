SUMMARY = "SOL development applications" 
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
    go-runtime \
    telegraf \
    stress-ng \
    rt-tests \
    memtester \
    e2fsprogs \
    tegra-pwrmon \
    offline-time-sync \
    net-tools \
    cuda-samples \
    enviro-test \
    lmsensors-libsensors \
    lmsensors-sensord \
    lmsensors-sensors \
    lmsensors-sensorsconfconvert \
"