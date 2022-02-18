DESCRIPTION = "Darknet for YOLO"
HOMEPAGE = "https://github.com/pjreddie/darknet.git"
LICENSE = "CLOSED"

SRC_URI = "git://github.com/pjreddie/darknet.git;protocol=https"
SRCREV = "a028bfa0da8eb96583c05d5bd00f4bfb9543f2da"

SRC_URI += "file://cross_compile.patch"

EXTRA_OEMAKE += "'CC=${CC}' 'CXX=${CXX}' 'NVCC=/usr/local/cuda-10.0/bin/nvcc -ccbin /usr/bin/aarch64-linux-gnu-g++' 'GPU=1' 'CUDNN=1' 'LDFLAGS=--hash-style=gnu -L${WORKDIR}/recipe-sysroot/${libdir}'"
S = "${WORKDIR}/git"

RDEPENDS_${PN} = " \
    cuda-cusolver \
    cuda-cublas \
    cuda-cudart \
    cuda-curand \
    cudnn \
"

DEPENDS = "cudnn"

do_compile() {
    mkdir -p obj
    oe_runmake darknet
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/darknet ${D}${bindir}/darknet-gpu-cudnn
}