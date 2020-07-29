SECTION = "kernel"
SUMMARY = "Linux for Tegra kernel dtb"
DESCRIPTION = "Linux kernel from sources provided by Nvidia for Tegra processors."
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"



FILESEXTRAPATHS_prepend := "${THISDIR}/files:${THISDIR}/${BPN}-${@bb.parse.BBHandler.vars_from_file(d.getVar('FILE', False),d)[1]}:"
SRC_URI_append = " file://tegra186-quill-p3489-1000-a00-00-ucm1-sol-custom.dts"


do_configure_append() {
    #DTB will only be used if specified in the machine conf file
    install -d 0644 ${B}/arch/${ARCH}/boot/dts/
	install -m 0644 "${WORKDIR}/tegra186-quill-p3489-1000-a00-00-ucm1-sol-custom.dts" "${B}/arch/${ARCH}/boot/dts/tegra186-quill-p3489-1000-a00-00-ucm1-sol-custom.dts"
}


COMPATIBLE_MACHINE = "(tegra)"
