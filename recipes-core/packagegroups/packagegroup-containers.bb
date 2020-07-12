SUMMARY = "SOL development applications" 
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
    docker-ce \
    python3-docker-compose \
    nvidia-container-runtime \
"