SUMMARY = "SOL core image - directly copied from core-image-minimal"

IMAGE_LINGUAS = " "

LICENSE = "MIT"

# Packages to install
IMAGE_INSTALL = "packagegroup-core-boot \
    ${CORE_IMAGE_EXTRA_INSTALL} \
    packagegroup-sol-core \
    tegra-firmware-xusb \
"

IMAGE_CLASSES += "image_types_tegra"
IMAGE_FSTYPES = "tegraflash"

inherit core-image

IMAGE_ROOTFS_SIZE ?= "8192"
IMAGE_ROOTFS_EXTRA_SPACE_append = "${@bb.utils.contains("DISTRO_FEATURES", "systemd", " + 4096", "" ,d)}"
