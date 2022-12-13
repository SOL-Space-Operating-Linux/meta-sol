DESCRIPTION = "Darknet for YOLO"
HOMEPAGE = "https://github.com/pjreddie/darknet.git"
LICENSE = "CLOSED"

SRC_URI = "git://github.com/AlexeyAB/darknet.git;protocol=https"
SRCREV = "6af4370c3fe0f43a8c2fea6e04fc3dd2930b1da5"

SRC_URI += "file://cross_compile.patch"

EXTRA_OEMAKE += "GPU=1 CC='/usr/bin/aarch64-linux-gnu-g++' CPP='/usr/bin/aarch64-linux-gnu-g++' NVCC='/usr/local/cuda-10.0/bin/nvcc -ccbin /usr/bin/aarch64-linux-gnu-g++'"
PARALLEL_MAKE = "-j8"

S = "${WORKDIR}/git"

RDEPENDS_${PN} = " \
    cuda-cusolver \
    cuda-cublas \
    cuda-cudart \
    cuda-curand \
    tegra-libraries \
"

DEPENDS = "cuda-nvcc cuda-cusolver cuda-cublas cuda-cudart cuda-curand"

do_compile() {
    export LD_LIBRARY_PATH=${STAGING_DIR_HOST}/lib:${STAGING_DIR_HOST}/usr/lib
    mkdir -p obj
    oe_runmake darknet
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/darknet ${D}${bindir}/darknet

    install -d ${D}/etc
    install -d ${D}/etc/yolo
    install -d ${D}/etc/yolo/labels
    install -m 0755 ${THISDIR}/etc/labels/* ${D}/etc/yolo/labels/
    install -m 0755 ${THISDIR}/etc/classes.names ${D}/etc/yolo/classes.names
    install -m 0755 ${THISDIR}/etc/moci.cfg ${D}/etc/yolo/moci.cfg
    install -m 0755 ${THISDIR}/etc/moci.data ${D}/etc/yolo/moci.data
    install -m 0755 ${THISDIR}/etc/moci.weights ${D}/etc/yolo/moci.weights
}