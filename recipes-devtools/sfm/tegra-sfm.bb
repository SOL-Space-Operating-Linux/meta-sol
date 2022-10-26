DESCRIPTION = "Tegra-SFM"
HOMEPAGE = "https://gitlab.smallsat.uga.edu/payload_software/Tegra-SFM"
LICENSE = "CLOSED"

SRC_URI = "git://128.192.19.18/payload_software/SSRLCV.git;protocol=ssh;user=git;branch=master"
SRCREV = "00c9e7b97c658046ba57d5ee7604903bb710899b"

FILES_${PN} += "${libdir}/*.so.*"

COMPATIBLE_MACHINE = "(tegra)"

INHIBIT_PACKAGE_STRIP = "1"

S = "${WORKDIR}/git"

TARGET_CC_ARCH += "${LDFLAGS}"
INSANE_SKIP_${PN} += "dev-deps"
INSANE_SKIP_${PN} += "already-stripped"
INSANE_SKIP_${PN} += "ldflags"
INSANE_SKIP_${PN} += "dev-elf"
INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"
SOLIBS = ".so .so.8"
FILES_SOLIBSDEV = ""

RDEPENDS_${PN} = " \
    cuda-cusolver \
    cuda-cublas \
    cuda-cudart \
    tegra-libraries \
"

export NVCC
NVCC = "/usr/local/cuda-10.0/bin/nvcc -ccbin /usr/bin/aarch64-linux-gnu-g++"
CXX = "/usr/bin/aarch64-linux-gnu-g++"
INCLUDES = "-I. -I./include -I/usr/local/cuda/include -I/usr/local/libpng/include/libpng15"

EXTRA_OEMAKE = "'NVCC=${NVCC}' 'LINK=${NVCC}' 'CXX=${CXX}' 'INCLUDES=${INCLUDES}'" 
PARALLEL_MAKE = "-j8"

do_compile() {
	export CPATH=/usr/local/cuda-10.0/targets/aarch64-linux/include:$CPATH
	export LD_LIBRARY_PATH=/usr/lib:$LD_LIBRARY_PATH
	export PKG_CONFIG_PATH=/usr/lib/pkgconfig:$PKG_CONFIG_PATH
        oe_runmake -C ${S} sfm SM=62
}

do_install() {
    install -d ${D}${libdir}
    install -m 0644 ${THISDIR}/files/libpng15.so.15 ${D}${libdir}/libpng15.so.15
    install -m 0644 ${THISDIR}/files/libjpeg.so.8 ${D}${libdir}/libjpeg.so.8
    install -m 0644 ${THISDIR}/files/libz.so ${D}${libdir}/libz.so

    install -d ${D}${bindir}
    install -m 0755 ${S}/bin/SFM ${D}${bindir}
}

