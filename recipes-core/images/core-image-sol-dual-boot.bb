SUMMARY = "SOL core development image"

LICENSE = "MIT"


IMAGE_CLASSES += "image_types_tegralive"
IMAGE_TEGRAFLASH_FS_TYPE = "ext4.live"
#remove this line if you want a faster larger build (just tar, no xz)
LIVE_IMAGE_COMPRESSION = "xz" 

#inherit core-image image_types_tegra
require core-image-sol.bb



# Development features
IMAGE_FEATURES += "ssh-server-dropbear post-install-logging \
    debug-tweaks dbg-pkgs \
"

# Packages to install
IMAGE_INSTALL += "packagegroup-core-buildessential \
    packagegroup-devtools \
"

# Set root password (password = "tegratest")
inherit extrausers
IMAGE_FEATURES_remove = "allow-empty-password empty-root-password"
EXTRA_USERS_PARAMS = "usermod -P tegratest root;"