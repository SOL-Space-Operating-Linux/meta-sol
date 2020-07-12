SUMMARY = "SOL core dependencies" 
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
    cuda-toolkit \
    tegra-tools \
    tegra-nvpmodel \
    python3 \
    tegra-redundant-boot \
"