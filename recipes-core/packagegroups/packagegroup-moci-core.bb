SUMMARY = "MOCI core dependencies" 
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
    python3 \
    python3-pip \
    tegra-sfm \
    moyoloci \
    cuda-toolkit \
"
