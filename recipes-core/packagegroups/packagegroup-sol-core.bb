SUMMARY = "SOL core dependencies" 
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
    imagemagick \
    zlib \
    libpng \
    cmake \
    python3 \
    tegra-redundant-boot \
    tegra-nvpmodel \
"
