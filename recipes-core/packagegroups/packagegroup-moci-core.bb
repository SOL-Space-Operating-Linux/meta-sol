SUMMARY = "MOCI core dependencies" 
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
    python3 \
    python3-numpy \
    python3-tqdm \
    python3-pyserial \
    python3-matplotlib \
    python3-crcmod \
    python3-pillow \
    python3-terminaltables \
    tegra-sfm \
    moyoloci \
    cuda-toolkit \
"
