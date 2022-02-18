DESCRIPTION = "Darknet for YOLO"
HOMEPAGE = "https://github.com/pjreddie/darknet.git"
LICENSE = "CLOSED"

SRC_URI = "git://github.com/pjreddie/darknet.git;protocol=https"
SRCREV = "a028bfa0da8eb96583c05d5bd00f4bfb9543f2da"

SRC_URI += "file://cross_compile.patch"

CC_BIN = "${@'${CC}'.split(' ')[0] + ' ' + ' '.join(['-Xcompiler ' + flag for flag in '${CC}'.split()[1:]])}"
export CC_BIN

EXTRA_OEMAKE += "'CC=${CC}' 'CXX=${CXX}' 'NVCC=${STAGING_DIR_HOST}/${baselibdir}/usr/local/cuda-${CUDA_VERSION}/bin/nvcc -ccbin ${CC_BIN}' 'GPU=1' 'LDFLAGS=--hash-style=gnu'"
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
    install -m 0755 ${S}/darknet ${D}${bindir}/darknet-gpu
}