DESCRIPTION = "install a custom flash_l4t_<machine>.xml file for a redundant, live boot setup"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI = "file://flash_t186_redundant_rootfs.xml"
SRC_URI = "file://flash_t186_sol_single_rootfs.xml"


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


do_install_prepend() {
    install -m 0644 ${WORKDIR}/flash_t186_redundant_rootfs.xml "${S}/bootloader/${NVIDIA_BOARD}/cfg/flash_t186_redundant_rootfs.xml"
    install -m 0644 ${WORKDIR}/flash_t186_sol_single_rootfs.xml "${S}/bootloader/${NVIDIA_BOARD}/cfg/flash_t186_sol_single_rootfs.xml"
}


