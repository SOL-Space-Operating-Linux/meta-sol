SUMMARY = "SOL development applications" 
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
    cuda-samples \
    cuda-core-dev \
    cuda-toolkit-dev \
    tegra-tools \
    haveged \
    bash util-linux \
    vim git curl wget \
    unzip usbutils \
"