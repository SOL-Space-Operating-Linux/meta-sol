# meta-sol
Yocto layer for Space Operating Linux



Machine required in local.conf:

```MACHINE = "jetson-tx2i"```

Layers required in bblayers.conf

```BBLAYERS ?= " \
  /home/aplsim/development/scis/sol/poky-tx2/meta \
  /home/aplsim/development/scis/sol/poky-tx2/meta-poky \
  /home/aplsim/development/scis/sol/poky-tx2/meta-yocto-bsp \
  /home/aplsim/development/scis/sol/poky-tx2/meta-tegra \
  /home/aplsim/development/scis/sol/poky-tx2/meta-linaro/meta-linaro-toolchain \
  /home/aplsim/development/scis/sol/poky-tx2/meta-cti \
  /home/aplsim/development/scis/sol/poky-tx2/meta-openembedded/meta-oe \
  /home/aplsim/development/scis/sol/poky-tx2/meta-sol \
  "
```

Build via 
```bitbake core-image-sol```

