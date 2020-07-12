SUMMARY = "SOL development applications" 
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
    haveged \
    bash util-linux \
    nano vim git curl wget \
    unzip usbutils \
"