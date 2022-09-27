# SOL (Space Operating Linux) 

## Table of Contents
- [SOL (Space Operating Linux)](#sol-space-operating-linux)
  - [Table of Contents](#table-of-contents)
  - [Setting up Environment for Local Development](#setting-up-environment-for-local-development)
    - [Preparing Containers, Directories, and Files](#preparing-containers-directories-and-files)
      - [A Note on Terminals](#a-note-on-terminals)
      - [Create the Poky Work Directory](#create-the-poky-work-directory)
      - [Download the NVIDIA SDK Files](#download-the-nvidia-sdk-files)
      - [Run the CROPS Docker Container and Clone the Necessary Repositories](#run-the-crops-docker-container-and-clone-the-necessary-repositories)
    - [Modifying Build Configurations](#modifying-build-configurations)
    - [Manually Update the `tegra-eeprom` Recipe](#manually-update-the-tegra-eeprom-recipe)
  - [Building the Image with BitBake](#building-the-image-with-bitbake)
  - [Flashing the TX2/TX2i](#flashing-the-tx2tx2i)
  - [Useful Commands](#useful-commands)
  - [List of Useful References](#list-of-useful-references)

## Setting up Environment for Local Development

(This section may be skipped if you are using the SSRL build server.)

### Preparing Containers, Directories, and Files

*Note*: If you plan on building on your own machine, be aware that Yocto builds from scratch can take up a LOT of CPU time (several hours) and drive space (hundreds of GB).

This process was tested on an x86_64 laptop running Ubuntu 22.04 but should work on any system that can support Dockers. The actual build takes place inside of a [CROPS Poky container](https://github.com/crops/poky-container) based on Ubuntu 18.04 which has all the necessary build dependencies pre-installed. Make sure to [install Docker first](https://docs.docker.com/engine/install/ubuntu/) and [optionally modify user groups](https://docs.docker.com/engine/install/linux-postinstall/) to allow non-root user access.

#### A Note on Terminals

Two terminals are used to complete this process:

- The first terminal, called **[tty-host]** in this document, is the "host terminal". It's a shell run on the host machine and is where Docker is invoked from and configuration files are edited.

- The second one, called **[tty-build]**, is the "Poky terminal", and is where the actual build environment exists. This is the Ubuntu 18.04 CROPS container being run in interactive mode with a pseudo-TTY. It is designed only for building images with Yocto and doesn't have software like editors or the capability to easily install them. This container has a [bind mount](https://docs.docker.com/storage/bind-mounts/) that it shares with the host environment to more easily work with configuration files and build artifacts

#### Create the Poky Work Directory

- Assign a working directory on the host machine and set it as an environment variable
  ```bash
  # user@tty-host
  SOLWORK=/home/$USER/sol-workdir 
  ```

- Create the directory if it doesn't already exist
  ```bash
  # user@tty-host
  mkdir -p $SOLWORK
  ```

#### Download the NVIDIA SDK Files

- Use the host terminal to download the [NVIDIA SDK Manager Docker Image for Ubuntu 18.04](https://developer.nvidia.com/nvidia-sdk-manager-sdkmanager-docker-image-ubuntu1804) (requires an NVIDIA developer account). See [this page](https://docs.nvidia.com/sdk-manager/docker-containers/index.html) for more info on getting the Docker image, specifically the _Known Issues_ section about `qemu-user-static`.

- Create the directory where the SDK will be downloaded
  ```bash
  # user@tty-host
  mkdir -p $SOLWORK/nvidia/sdkm_downloads
  ```

- Load the SDK Manager image into Docker 
  ```bash
  # user@tty-host
  docker load -i [path-to-sdkmanager]/sdkmanager-[version].[build_number]-[base_OS]_docker.tar.gz
  # For example:
  # docker load -i ~/Downloads/sdkmanager-1.8.3.10426-Ubuntu_18.04_docker.tar.gz
  ```

- Launch the SDK Manager container passing in the SDK download directory and other CLI arguments to get version 4.3 of the JetPack SDK (L4T 32.3.1)
  ```bash
  # user@tty-host
  docker run -it --rm -v $SOLWORK:/workdir --name JetPack_TX2i_DevKit_DL sdkmanager:1.8.3.10426-Ubuntu_18.04 \
  --cli downloadonly --downloadfolder /workdir/nvidia/sdkm_downloads --showallversions --archivedversions \
  --logintype devzone --product Jetson --target P3310-1000 --targetos Linux --host --version 4.3 --select 'Jetson OS' \
  --select 'Jetson SDK Components' --license accept --staylogin true --datacollection disable 
  ```

#### Run the CROPS Docker Container and Clone the Necessary Repositories

- Launch the CROPS container passing in the SOLWORK variable
  ```bash
  # user@tty-host
  docker run -it -v $SOLWORK:/workdir crops/poky:ubuntu-18.04 --workdir=/workdir
  ```

- Clone the Poky `zeus` branch and change into the repo directory
  ```bash
  # pokyuser@tty-build
  git clone git://git.yoctoproject.org/poky -b zeus
  cd poky
  ```

- Clone the meta-tegra `zeus-l4t-r32.3.1` branch, the SOL `zeus-l4t-r32.3.1-kernel-tmr` branch, and the `meta-openembedded` `zeus` branch
  ```bash
  # pokyuser@tty-build
  git clone https://github.com/madisongh/meta-tegra.git -b zeus-l4t-r32.3.1
  git clone https://github.com/SOL-Space-Operating-Linux/meta-sol.git -b zeus-l4t-r32.3.1-kernel-tmr
  git clone https://github.com/openembedded/meta-openembedded.git -b zeus
  ```

### Modifying Build Configurations

Once Poky and all the required meta layers are cloned, you must source the bash environment provided with Poky.
This will put useful tools (most importantly bitbake) in your path that will be used to build the TX2i image.
This operation must be done every time you logout/start a new terminal.

- Change directory to the parent work directory and source the Yocto environment variables
  ```bash
  # pokyuser@tty-build
  cd /workdir
  source poky/oe-init-build-env tx2i-build
  ```

This will put you in the `tx2i-build` folder, and create it if you have not already done this before.
This folder will eventually contain all downloaded files, build files, and images.
You will find that there is only a conf folder that contains the `bblayers.conf` and `local.conf` configuration files.

`bblayers.conf`: Contains directory paths for all the required meta layers for a build

`local.conf`: Contains all user defined configurations for the build target

Reference https://www.yoctoproject.org/docs/3.0/ref-manual/ref-manual.html#ref-structure for more information on the directory structure of the Yocto project.

*Note*: You can find a template for these two files under `meta-sol/conf/*.conf.template`.

- Use `bitbake-layers` to add the `meta-tegra`, `meta-tegra` community contributions, `meta-sol`,  and `meta-oe` layers to `/workdir/tx2i-build/conf/bblayers.conf`
  ```bash
  # pokyuser@tty-build
  bitbake-layers add-layer ../poky/meta-tegra/ ../poky/meta-tegra/contrib/ ../poky/meta-sol/ ../poky/meta-openembedded/meta-oe/
  ```

Your bblayers variable in the bblayers.conf should look like the following:

```
BBLAYERS ?= " \
  /workdir/poky/meta \
  /workdir/poky/meta-poky \
  /workdir/poky/meta-yocto-bsp \
  /workdir/poky/meta-tegra \
  /workdir/poky/meta-tegra/contrib \
  /workdir/poky/meta-sol \
  /workdir/poky/meta-openembedded/meta-oe \
  "
  ```

The next step is to tell BitBake what machine to target, where the NVIDIA SDK files are located, and what version of CUDA to use.

*Note*: In the code snippets, "+" at the beginning of a line means "add this line" (but without the + symbol) and "-" at the beginning of a line means remove this line.

- Edit (in **[tty-host]**) `$SOLWORK/tx2i-build/conf/local.conf` with the following changes
  ```bash
  # user@tty-host
  - MACHINE ??= "qemux86-64"
  + #MACHINE ??= "qemux86-64"
  + MACHINE="jetson-tx2i-sol-redundant-live"
  + NVIDIA_DEVNET_MIRROR = "file:///workdir/nvidia/sdkm_downloads"
  + CUDA_VERSION = "10.0"
  ```

### Manually Update the `tegra-eeprom` Recipe

Due to upstream changes in `tegra-eeprom-tool`, we need to remove the current recipe and replace it with the upstream one, and then modify it to work with this version of Yocto. 

- Change into the location where the `tegra-eeprom-tool` is located, remove the existing recipe, and grab the upstream recipe from the `master` branch
  ```bash
  # user@tty-host
  cd $SOLWORK/poky/meta-tegra/recipes-bsp/tools
  rm tegra-eeprom-tool_git.bb
  git checkout origin/master -- tegra-eeprom-tool_2.0.0.bb
  ```

- Edit (in **[tty-host]**) `tegra-eeprom-tool_2.0.0.bb` the variables that use colons and replace them with underscores
  ```bash
  # user@tty-host
  - RRECOMMENDS:${PN} += "kernel-module-at24"
  + RRECOMMENDS_${PN} += "kernel-module-at24"

  - FILES:${PN}-boardspec = "${bindir}/tegra-boardspec"
  + FILES_${PN}-boardspec = "${bindir}/tegra-boardspec"
  ```    

## Building the Image with BitBake

It's finally time to kick off the build. Keep in mind that this can take a very long time. Subsequent builds should be much quicker depending on what is changed and if the tmp, cache, downloads, and sstate-cache directories have not been deleted.

- In **[tty-build]**, run the BitBake command (with an optional timer to see how long the command took to run) and the -k flag to continue building as much of the project as possible instead of failing on the first error. 
  ```bash
  # pokyuser@tty-build
  time bitbake -k core-image-sol-dev
  ```

- Alternatively, you can build `core-image-sol` without the development packages or `core-image-minimal` for a minimal build for the TX2.
within the tx2i-build directory:
  ```bash
  # pokyuser@tty-build
  time bitbake -k core-image-sol
  time bitbake -k core-image-minimal
  ```
*Note*: If you do `core-image-minimal`, then you must manually append these lines into your `local.conf` file.
```
IMAGE_CLASSES += "image_types_tegra"
IMAGE_FSTYPES = "tegraflash"
```

*Note*: If you are attempting to build for a Jetson Nano, this README does not have all steps necessary to successfully build. Please reference the `meta-tegra` repository for more information on Jetson Nano.

## Flashing the TX2/TX2i
All completed images are saved to the `$SOLWORK/tx2i-build/tmp/deploy/images` directory.
`meta-tegra` includes an option to build an image that comes with a script to flash the TX2/TX2i.
This was included in the image files with `IMAGE_CLASSES += "image_types_tegra"` and `IMAGE_FSTYPES = "tegraflash"`. There will be a file named something similar to `core-image-sol-jetson-tx2i.tegraflash.zip`.

1. Download the zip file to your host machine that you will flash the TX2/TX2i from and unzip.

2. Connect the TX2/TX2i to your host machine with a micro-usb cable.

*Note*: If your computer does not detect the TX2/TX2i at step 4 it could be because a cable without data lines was used.

3. From a cold boot, hold down the recovery button and keep it held.
    Press the power button.
    Then, press the reset button (there should be a quick flash of the dev board lights).
    Finally, release the recovery button after 2 seconds.

4. If the TX2/TX2i is successfully put into recovery mode, you should detect an `NVIDIA` device with the `lsusb` command.

5. To flash the device run the following command from within the unzipped directory:
   ```
   sudo ./doflash.sh
   ```

The TX2/TX2i should automatically reboot with the new image. Login with `root` user and no password.

To verify that CUDA is working enter the following commands.

*Note*: `cuda-samples` is only included in the `core-image-sol-dev` image.

```
cd /usr/bin/cuda-samples
./deviceQuery
./UnifiedMemoryStreams
```

## Useful Commands

- List of all packages for image target:
  ```
  bitbake -g <image> && cat pn-buildlist | grep -ve "native" | sort | uniq
  ```

- List all package and their versions for image target:
  ```
  cat tmp/deploy/images/*/core-image-sol-*.manifest
  ```

- List all layers for image target:
  ```
  bitbake-layers show-layers
  ```

## List of Useful References
- https://github.com/madisongh/meta-tegra/tree/zeus-l4t-r32.3.1
- https://github.com/madisongh/meta-tegra/wiki/Flashing-the-Jetson-Dev-Kit
- https://www.konsulko.com/building-a-custom-linux-distribution-for-nvidia-cuda-enabled-embedded-devices/
- https://docs.nvidia.com/jetson/archives/l4t-archived/l4t-3231/index.html#page/Tegra%2520Linux%2520Driver%2520Package%2520Development%2520Guide%2Fquick_start.html%23
- https://docs.nvidia.com/jetson/l4t/index.html
![Tegra_reference](./resources/tegra_reference.png)
- https://www.yoctoproject.org/docs/transitioning-to-a-custom-environment/
- https://www.yoctoproject.org/docs/3.0/ref-manual/ref-manual.html
- https://www.yoctoproject.org/docs/3.0/dev-manual/dev-manual.html
- https://www.yoctoproject.org/docs/1.0/poky-ref-manual/poky-ref-manual.html
- https://www.yoctoproject.org/docs/2.1/bitbake-user-manual/bitbake-user-manual.html
- https://www.yoctoproject.org/docs/3.0/kernel-dev/kernel-dev.html
- https://www.jetsonhacks.com/2017/03/24/serial-console-nvidia-jetson-tx2/
