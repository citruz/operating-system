#!/bin/bash
set -x

function hassos_pre_image() {
    local BOOT_DATA="$(path_boot_dir)"

    cp -t "${BOOT_DATA}" \
        "${BINARIES_DIR}/boot.scr" \
        "${BINARIES_DIR}/rockchip/"*.dtb

    mkdir -p "${BOOT_DATA}/overlays"
    cp "${BINARIES_DIR}/overlays/"*.dtbo "${BOOT_DATA}/overlays/"

    cp "${BOARD_DIR}/../boot-env-common.txt" "${BOOT_DATA}/haos-config.txt"
    cat "${BOARD_DIR}/boot-env.txt" >> "${BOOT_DATA}/haos-config.txt"
    cp "${BOARD_DIR}/../cmdline.txt" "${BOOT_DATA}/cmdline.txt"
}


function hassos_post_image() {
    convert_disk_image_xz
}

