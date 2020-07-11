SUMMARY = "SOL development applications" 
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

DISTRO_FEATURES_append = "virtualization"

RDEPENDS_${PN} = " \
    docker-ce \
    nvidia-docker \
"