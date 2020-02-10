SUMMARY = "SOL core image."

LICENSE = "MIT"
LICENSE_FLAGS_WHITELIST = "commercial"

inherit core-image image_types_tegra

#
# Jetson Specific Configurations
#

CUDA_VERSION = "10.0"
GCCVERSION = "7.%"
require contrib/conf/include/gcc-compat.conf

# This must be set in your local.conf in the build/conf directory.
# NVIDIA_DEVNET_MIRROR = "file:///home/$USER$/Downloads/nvidia/sdkm_downloads"

# Generates a .zip folder containing flashing scripts in
# tmp/deploy/images/$MACHINE$.
IMAGE_CLASSES += "image_types_tegra"
IMAGE_FSTYPES = "tegraflash"