#!/bin/bash
# shellcheck shell=bash

export BOARD_NAME="Orange Pi 5 Plus"
export BOARD_MAKER="Xulong"
export BOARD_SOC="Rockchip RK3588"
export BOARD_CPU="ARM Cortex A76 / A55"
export UBOOT_PACKAGE="u-boot-radxa-rk3588"
export UBOOT_RULES_TARGET="orangepi-5-plus-rk3588"

function config_image_hook__orangepi-5-plus() {
    local rootfs="$1"
    local overlay="$2"

    if [[ -z "$rootfs" || -z "$overlay" ]]; then
        echo "Usage: config_image_hook__orangepi-5-plus <rootfs> <overlay>"
        return 1
    fi

    # Install panfork
    if ! chroot "${rootfs}" add-apt-repository -y ppa:jjriek/panfork-mesa; then
        echo "Failed to add panfork repository."
        return 1
    fi
    if ! chroot "${rootfs}" apt-get update; then
        echo "Failed to update package lists."
        return 1
    fi
    if ! chroot "${rootfs}" apt-get -y install mali-g610-firmware; then
        echo "Failed to install mali-g610-firmware."
        return 1
    fi
    if ! chroot "${rootfs}" apt-get -y dist-upgrade; then
        echo "Failed to dist-upgrade."
        return 1
    fi

    # Install libmali blobs alongside panfork
    if ! chroot "${rootfs}" apt-get -y install libmali-g610-x11; then
        echo "Failed to install libmali-g610-x11."
        return 1
    fi

    # Install the rockchip camera engine
    if ! chroot "${rootfs}" apt-get -y install camera-engine-rkaiq-rk3588; then
        echo "Failed to install camera-engine-rkaiq-rk3588."
        return 1
    fi

    # Fix WiFi not working when bluetooth enabled for the official RTL8852BE WiFi + BT card
    mkdir -p "${rootfs}/usr/lib/scripts"
    if ! cp "${overlay}/usr/lib/systemd/system/rtl8852be-reload.service" "${rootfs}/usr/lib/systemd/system/rtl8852be-reload.service"; then
        echo "Failed to copy rtl8852be-reload.service."
        return 1
    fi
    if ! cp "${overlay}/usr/lib/scripts/rtl8852be-reload.sh" "${rootfs}/usr/lib/scripts/rtl8852be-reload.sh"; then
        echo "Failed to copy rtl8852be-reload.sh."
        return 1
    fi
    if ! chroot "${rootfs}" systemctl enable rtl8852be-reload; then
        echo "Failed to enable rtl8852be-reload service."
        return 1
    fi

    # Install wiring orangepi package 
    if ! chroot "${rootfs}" apt-get -y install wiringpi-opi libwiringpi2-opi libwiringpi-opi-dev; then
        echo "Failed to install wiringpi-opi packages."
        return 1
    fi
    echo "BOARD=orangepi5plus" > "${rootfs}/etc/orangepi-release"

    return 0
}
