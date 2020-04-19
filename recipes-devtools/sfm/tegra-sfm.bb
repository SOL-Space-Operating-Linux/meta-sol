DESCRIPTION = "Tegra-SFM"
HOMEPAGE = "https://gitlab.smallsat.uga.edu/payload_software/Tegra-SFM"
LICENSE = "CLOSED"

FILESEXTRAPATHS_prepend := "${THISDIR}:"
SRC_URI = "file://tegra-sfm.tar.gz"

COMPATIBLE_MACHINE = "(tegra)"

INHIBIT_PACKAGE_STRIP = "1"

S = "${WORKDIR}/Tegra-SFM"

do_unpack() {
    tar -C ${WORKDIR} -x -f ${THISDIR}/tegra-sfm/tegra-sfm.tar.gz
}

export NVCC
NVCC = "/usr/local/cuda-10.2/bin/nvcc"
EXTRA_OEMAKE = "'NVCC=${NVCC}' 'LINK=${NVCC}'"
PARALLEL_MAKE = "-j8"

do_compile() {
    if [[ $MACHINE = "jetson-tx2" ] || [ $MACHINE = "jetson-tx2i" ]]
    then
        oe_runmake sfm SM=52
    elif [[ $MACHINE = "jetson-tx2" ]]
    then
        oe_runmake sfm SM=53
    else
        bbfatal "Machine is not compatible with Tegra-SFM"
    fi
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/bin/SFM ${D}${bindir}
}