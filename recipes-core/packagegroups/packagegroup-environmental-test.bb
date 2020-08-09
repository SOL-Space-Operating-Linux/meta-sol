SUMMARY = "SOL development applications" 
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
    go-runtime \
    telegraf \
    stress-ng \
    rt-tests \
    lm-sensors \
    memtester \
"