SUMMARY = "MOCI core image"

LICENSE = "MIT"
LICENSE_FLAGS_WHITELIST = "commercial"

inherit core-image image_types_tegra
require core-image-sol.bb

#
# Jetson Specific Configurations
#

# This must be set in your local.conf in the build/conf directory.
# NVIDIA_DEVNET_MIRROR = "file:///home/$USER$/Downloads/nvidia/sdkm_downloads"

# Packages to install
IMAGE_INSTALL += "packagegroup-moci-core"