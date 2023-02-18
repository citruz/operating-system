#!/bin/bash
set -x

function hassos_pre_image() {
    local BOOT_DATA="$(path_boot_dir)"
    local SPL_IMG="$(path_spl_img)"

    cp -t "${BOOT_DATA}" \
        "${BINARIES_DIR}/boot.scr" \
        "${BINARIES_DIR}/rockchip/"*.dtb

    mkdir -p "${BOOT_DATA}/overlays"
    # replace .dtb extension with .dtbo
    for file in "${BINARIES_DIR}/rockchip/overlay/"*.dtb; do
        cp "$file" "${BOOT_DATA}/overlays/$(basename -- "$file" .dtb).dtbo"
    done

    cp "${BOARD_DIR}/../boot-env-common.txt" "${BOOT_DATA}/haos-config.txt"
    cat "${BOARD_DIR}/boot-env.txt" >> "${BOOT_DATA}/haos-config.txt"

    echo "earlycon=uart8250,mmio32,0xff1a0000 console=ttyS2,115200n8" > "${BOOT_DATA}/cmdline.txt"

    # SPL
    create_spl_image

    dd if="${BINARIES_DIR}/idbloader.img" of="${SPL_IMG}" conv=notrunc bs=512 seek=64  # 0x8000
    dd if="${BINARIES_DIR}/u-boot.itb" of="${SPL_IMG}" conv=notrunc bs=512 seek=8192  # 0x400000
}


function hassos_post_image() {
    convert_disk_image_xz
}

