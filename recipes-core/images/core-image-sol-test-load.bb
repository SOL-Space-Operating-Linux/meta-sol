SUMMARY = "SOL core development image"

LICENSE = "MIT"

#inherit core-image image_types_tegra
require core-image-sol-dev.bb

#
# Jetson Specific Configurations
#

# Packages to install
IMAGE_INSTALL_append = " packagegroup-containers \
"
