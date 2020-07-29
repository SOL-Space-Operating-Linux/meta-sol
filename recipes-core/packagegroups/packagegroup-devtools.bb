SUMMARY = "SOL development applications" 
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
    cuda-toolkit \
    cuda-samples \
    tegra-tools \
    haveged \
    bash util-linux \
    nano vim git curl wget \
    unzip usbutils \
    rt-tests \
"