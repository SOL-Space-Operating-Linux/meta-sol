DESCRIPTION = "Updates root file system (Since it's RAM-based)"
HOMEPAGE = "https://gitlab.smallsat.uga.edu/"
LICENSE = "CLOSED"

SRC_URI = "file://update_rootfs"


do_install() {
    install -d ${D}/usr
    install -d ${D}/usr/bin
    install -m 0755 ${THISDIR}/files/update_rootfs ${D}/usr/bin/update_rootfs

    sed -e "s/ROOTFS_FILE_OFFSET/${ROOTFS_FILE_OFFSET}/g" \
        -e "s/ROOTFS_FILE_BLOCKS/${ROOTFS_FILE_BLOCKS}/g" \
        -e "s/BLOCK_SIZE/${BLOCK_SIZE}/g" \
        -e "s/INFO_BYTES/${INFO_BYTES}/g" \
        -e "s/ROOTFS_HASH_OFFSET/${ROOTFS_HASH_OFFSET}/g" \
        -e "s/INFO_HASH_OFFSET/${INFO_HASH_OFFSET}/g" \
    -i ${D}/usr/bin/update_rootfs
}

RDEPENDS_${PN} += "bash tar"

