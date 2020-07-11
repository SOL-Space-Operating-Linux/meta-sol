SUMMARY = "SOL core development image"

LICENSE = "MIT"

#inherit core-image image_types_tegra
require core-image-sol-dev.bb

#
# Jetson Specific Configurations
#

DISTRO_FEATURES_append = " virtualization"

# Packages to install
IMAGE_INSTALL_append = "packagegroup-containers \
"
