#!/bin/bash

# Set Defaults if not provided
CUR_DIR=$(pwd)
# For Yocto Build
[ -z "${MACHINE}" ] && export MACHINE="jetson-nano-2gb-devkit"
[ -z "${BRANCH}" ] && export BRANCH="c4ef10f44d92ac9f1e4725178ab0cefd9add8126"
[ -z "${DISTRO}" ] && export DISTRO="tegrademo"
[ -z "${BUILD_IMAGE}" ] && export BUILD_IMAGE="demo-image-full"
[ -z "${NVIDIA_DEVNET_MIRROR}" ] && export NVIDIA_DEVNET_MIRROR="file:///home/user/sdk_downloads"
# For SDK Install
[ -z "${SDK_PRODUCT}" ] && export SDK_PRODUCT='--product Jetson'
[ -z "${SDK_VERSION}" ] && export SDK_VERSION='--version 4.5.1'
[ -z "${SDK_TGTOS}" ] && export SDK_TGTOS='--targetos Linux'
[ -z "${SDK_ASHOST}" ] && export SDK_ASHOST='--host true'
[ -z "${SDK_TGTMACH}" ] && export SDK_TGTMACH='--target P3448-0003'
[ -z "${SDK_FLASH}" ] && export SDK_FLASH='--flash skip'
[ -z "${SDK_ADDITIONS}" ] && export SDK_ADDITIONS='--additionalsdk TensorFlow'
[ -z "${SDK_SELECTIONS}" ] && export SDK_SELECTIONS='--select "Jetson OS" --select "Jetson SDK Components"'
[ -z "${SDK_LICENSE}" ] && export SDK_LICENSE='--license accept'
[ -z "${SDK_DATACOLLECT}" ] && export SDK_DATACOLLECT='--datacollection disable'
[ -z "${SDK_DLDIR}" ] && export SDK_DLDIR='--downloadfolder /home/user/sdk_downloads'
[ -z "${SDK_IMGDIR}" ] && export SDK_IMGDIR='--targetimagefolder /home/user/nvidia/nvidia_sdk/'

# Installs the nVidia SDK
sdkmanager --cli install --staylogin true ${SDK_PRODUCT} ${SDK_VERSION} \
    ${SDK_TGTOS} ${SDK_ASHOST} ${SDK_TGTMACH} ${SDK_FLASH} ${SDK_ADDITIONS} \
    '${SDK_SELECTIONS}' ${SDK_LICENSE} ${SDK_DATACOLLECT} ${SDK_DLDIR} \
    ${SDK_IMGDIR} --sudopassword '\n'

# Clone L4T Yocto Base
YL4T_SUCCESS="false"
git clone https://github.com/OE4T/tegra-demo-distro.git ${CUR_DIR}/tegra-demo-distro
cd "${CUR_DIR}/tegra-demo-distro/" || echo "Could not enter L4T directory"
git checkout ${BRANCH}
git submodule update --init --recursive

# Begin L4T Tegra Build
bitbake ${BUILD_IMAGE} && export YL4T_SUCCESS="true"

if [ "${YL4T_SUCCESS}" = "true" ]; then
    echo "Yocto Build of L4T Complete. Preping Image to flash to SD Card."
    mkdir -p "${CUR_DIR}/tegraflash"
    cd "${CUR_DIR}/tegraflash" || echo "Could Not Enter SD Card Staging Directory"
    cp "${CUR_DIR}/tegra-demo-distro/build/tmp/deploy/images/${MACHINE}/${BUILD_IMAGE}-${MACHINE}.tegraflash.tar.gz" "${CUR_DIR}/tegraflash/"
    tar -xf "${CUR_DIR}/tegra-demo-distro/build/tmp/deploy/images/${MACHINE}/${BUILD_IMAGE}-${MACHINE}.tegraflash.tar.gz"
    [ -f "../${BUILD_IMAGE}-${MACHINE}.img" ] && rm -rf "../${BUILD_IMAGE}-${MACHINE}.img"
    ./dosdcard.sh "../${BUILD_IMAGE}-${MACHINE}.img" && SDCARD_IMAGE="true"

    echo "" && echo ""
    echo "####################################################################################################"
    echo "Yocto has finished building the OE4T image \"${BUILD_IMAGE}\" for the \"${MACHINE}\"."
    echo "Deloyment files can be found here: ${CUR_DIR}/tegra-demo-distro/build/tmp/deploy/images/${MACHINE}/"
    if [ "${SDCARD_IMAGE}" = "true" ]; then
        echo ""
        echo "SD Card image for flashing can be found here: ${CUR_DIR}/${BUILD_IMAGE}-${MACHINE}.img"
    else
        echo "Yocto Build of OE4T Complete. SD Card Image creation has failed."
        echo "Follow the steps echo'ed below to try again (externally from docker)"
        echo 'mkdir -p "$PWD/tegraflash" && cd "$PWD/tegraflash"'
        echo 'cp "$PWD/tegra-demo-distro/build/tmp/deploy/images/${MACHINE}/${BUILD_IMAGE}-${MACHINE}.tegraflash.tar.gz" .'
        echo 'tar -xf "$PWD/tegra-demo-distro/build/tmp/deploy/images/${MACHINE}/${BUILD_IMAGE}-${MACHINE}.tegraflash.tar.gz"'
        echo './dosdcard.sh "../${BUILD_IMAGE}-${MACHINE}.img"'
    fi
    echo "####################################################################################################"
    echo ""
    exit 0
    
else
    echo "Could not determine the success of Yocto building L4T; exiting..."
    exit 1
fi
