DESCRIPTION = "install a custom flash_l4t_<machine>.xml file for a redundant, live boot setup"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${MACHINE}:${THISDIR}/${PN}:"

SRC_URI = "file://flash_t186_redundant_rootfs.xml \
           file://flash_t186_default_rootfs.xml \
           file://smd_info.redundant.cfg \
           "


#APL Configs
SRC_URI_append_jetson-tx2i-sol-apl = " file://tegra186-mb1-bct-bootrom-quill-p3489-1000-a00-sol-custom.cfg \
           file://tegra186-mb1-bct-misc-si-l4t-sol-custom.cfg \
           file://tegra186-mb1-bct-pad-quill-p3489-1000-a00-sol-custom.cfg \
           file://tegra186-mb1-bct-pinmux-quill-p3489-1000-a00-sol-custom.cfg \
           file://tegra186-mb1-bct-pmic-quill-p3489-1000-a00-sol-custom.cfg \
           file://tegra186-mb1-bct-prod-storm-p3489-1000-a00-sol-custom.cfg \
           "



python do_sol_unpack () {

    print('do_additional_unpack is now running')
    src_uri = (d.getVar('SRC_URI') or "").split()
    if len(src_uri) == 0:
        return

    try:
        fetcher = bb.fetch2.Fetch(src_uri, d)
        fetcher.unpack(d.getVar('WORKDIR'))
    except bb.fetch2.BBFetchException as e:
        bb.fatal(str(e))
}

addtask do_sol_unpack before do_install

do_compile_prepend() {
    install -m 0644 ${WORKDIR}/smd_info.redundant.cfg "${S}/bootloader/smd_info.redundant.cfg"
}


do_install_append() {
    #Flash layouts
    install -m 0644 ${WORKDIR}/flash_t186_redundant_rootfs.xml "${S}/bootloader/${NVIDIA_BOARD}/cfg/flash_t186_redundant_rootfs.xml"
    install -m 0644 ${WORKDIR}/flash_t186_default_rootfs.xml "${S}/bootloader/${NVIDIA_BOARD}/cfg/flash_t186_default_rootfs.xml"

}

do_install_append_jetson-tx2i-sol-apl() {
    #APL Configs
    install -m 0644 ${WORKDIR}/tegra186* ${D}${datadir}/tegraflash/
    install -m 0644 ${S}/bootloader/${NVIDIA_BOARD}/tegra186-a02-bpmp*dtb ${D}${datadir}/tegraflash/
    install -m 0644 ${S}/bootloader/${NVIDIA_BOARD}/BCT/minimal_scr.cfg ${D}${datadir}/tegraflash/
    install -m 0644 ${S}/bootloader/${NVIDIA_BOARD}/BCT/mobile_scr.cfg ${D}${datadir}/tegraflash/
    install -m 0644 ${S}/bootloader/${NVIDIA_BOARD}/BCT/emmc.cfg ${D}${datadir}/tegraflash/
}
