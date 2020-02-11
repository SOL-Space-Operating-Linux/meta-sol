SUMMARY = "SOL core image"

LICENSE = "MIT"
LICENSE_FLAGS_WHITELIST = "commercial"

inherit core-image image_types_tegra

#
# Jetson Specific Configurations
#

# This must be set in your local.conf in the build/conf directory.
# NVIDIA_DEVNET_MIRROR = "file:///home/$USER$/Downloads/nvidia/sdkm_downloads"

# Generates a .zip folder containing flashing scripts in
# tmp/deploy/images/$MACHINE$.
IMAGE_CLASSES += "image_types_tegra"
IMAGE_FSTYPES = "tegraflash"

# Packages to install
IMAGE_INSTALL = "packagegroup-core-boot packagegroup-sol-core"