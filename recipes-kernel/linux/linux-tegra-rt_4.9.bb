SECTION = "kernel"
SUMMARY = "Linux for Tegra kernel recipe with RT patches included"
DESCRIPTION = "Linux kernel from sources provided by Nvidia for Tegra processors. This is a clone of the meta-tegra linux-tegra."
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"

inherit kernel

PV .= "+git${SRCPV}"
FILESEXTRAPATHS_prepend := "${THISDIR}/files:${THISDIR}/${BPN}-${@bb.parse.BBHandler.vars_from_file(d.getVar('FILE', False),d)[1]}:"
EXTRA_OEMAKE += 'LIBGCC=""'

L4T_VERSION = "l4t-r32.3.1"
SCMVERSION ??= "y"
export LOCALVERSION = ""

SRCBRANCH = "patches-${L4T_VERSION}"
SRCREV = "47e7e1cb0b492487faa6258a4f3efe91676568b7"
KERNEL_REPO = "github.com/madisongh/linux-tegra-4.9"
SRC_URI = "git://${KERNEL_REPO};branch=${SRCBRANCH} \
       file://tegra186-quill-p3489-1000-a00-00-ucm1-sol-custom.dts \
	   file://defconfig_rt \
"
S = "${WORKDIR}/git"




do_configure_prepend() {

    #DTB will only be used if specified in the machine conf file
    install -d 0644 ${B}/arch/${ARCH}/boot/dts/
	install -m 0644 "${WORKDIR}/tegra186-quill-p3489-1000-a00-00-ucm1-sol-custom.dts" "${B}/arch/${ARCH}/boot/dts/tegra186-quill-p3489-1000-a00-00-ucm1-sol-custom.dts"

    #Add RT patches to kernel source repo
    #This should possibly be moved to do_patch_append
    bbdebug 1 ${S}
    cd ${S}
    for i in rt-patches/*.patch; 
        do bbdebug 1 $i; 
    done
    for i in rt-patches/*.patch; 
        do patch -p1 < $i; 
    done
    cd -

    #Copy rt defconfig to .config
    localversion="-${L4T_VERSION}"
    if [ "${SCMVERSION}" = "y" ]; then
	head=`git --git-dir=${S}/.git rev-parse --verify --short HEAD 2> /dev/null`
        [ -z "$head" ] || localversion="${localversion}+g${head}"
    fi
    sed -e"s,^CONFIG_LOCALVERSION=.*$,CONFIG_LOCALVERSION=\"${localversion}-rt\"," \
	< ${WORKDIR}/defconfig_rt > ${B}/.config
}

COMPATIBLE_MACHINE = "(tegra)"

RDEPENDS_${KERNEL_PACKAGE_NAME}-base = "${@'' if d.getVar('PREFERRED_PROVIDER_virtual/bootloader').startswith('cboot') else '${KERNEL_PACKAGE_NAME}-image'}"
