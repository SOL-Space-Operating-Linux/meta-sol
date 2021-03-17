SUMMARY = "MOCI core dependencies" 
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
    python3 \
    tegra-sfm \
    moyoloci \
    cuda-cusolver \
    cuda-cublas \
    cuda-cudart \
"
