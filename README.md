# Home Assistant OS for Rock Pi 4B+

This is an unofficial fork of the awesome [Home Assistant Operating System](https://github.com/home-assistant/operating-system) which adds support for the Rock Pi 4 board family.

## Supported boards

This is build is developed and tested mainly on the Rock Pi 4B+. However, users have reported that it also works on other boards which use very similar hardware:

- Rock Pi 4SE
- OKdo Rock 4C+

It might also work on other boards of the Rock Pi 4 family. Please try flashing it first before opening an issue. If it works, let me know so that I can add the board to the list.

You have a different Rock Pi board and would like to run Home Assistant on it? Please open an issue to get in contact.

## Installation

Download the latest version from the [Releases](https://github.com/citruz/haos-rockpi/releases) page, extract the image and flash it to your SD card or eMMC.

No further configuration should be required.

### Serial configuration

The serial baud rate is set to 1500000 as it is the default for the Rock Pi. If your serial interface cannot handle that speed, you can modify the kernel commandline to change it. To do this, mount the first partition of the image (fat) and modify `commandline.txt`.

## Boot from NMVe SSD

Booting HAOS from an NVMe SSD has been tested and is working for the Rock Pi 4B+. It may also work with other boards of the same family.

Please see the official Radxa site for which types of SSDs are supported: https://wiki.radxa.com/Rockpi4/install/NVME

Since the Rock Pi cannot boot natively from an SSD, you need a small bootloader either in eMMC or on an SD card (or in SPI flash for those models that have it, not tested). It performs the initialization and then loads the boot configuration, boot script and kernel files from the boot partition of the SSD.

`miniloader.img` is provided for that purpose on the Release page. It is 8MB in size and only contains the U-Boot bootloader (TPL, SPL and main).

### Option 1) miniloader in eMMC

This is the preferred way if you have a board with an eMMC module. You will need a spare SD card for the inital setup to flash both eMMC and the SSD.

1. Connect SSD to the board
1. Flash Armbian or another known working distro to the SD card and boot it
1. Destroy any remaining partitions on the eMMC storage, e.g. using `sgdisk -Z /dev/mmcblk1` (make sure `mmcblk1` is eMMC and not the SD card)
1. Flash `miniloader.img` to the eMMC. Either by copying it to Armbian and flashing from there or directly from your host via scp: `scp miniloader.img root@<armbian ip>:/dev/mmcblk1`
1. Flash HAOS image to the SSD. Same as above, can be done by copying or directly using scp: `scp haos_rockpi-4b-plus-<version>.img root@<armbian ip>:/dev/nvme0n1`
1. Remove SD card and reboot
1. There might be some error messages like `find_valid_gpt: *** ERROR: Invalid GPT ***`. These are expected because U-Boot will attempt to find the boot partition on eMMC first (it's not there). It should then recognize the NVMe SSD and boot from it.

### Option 2) miniloader on SD card

With this setup you always need to have an SD card inserted from which the board will load the bootloader.

1. Connect SSD to the board
1. Flash Armbian or another known working distro to the SD card and boot it
1. Flash HAOS image to the SSD. Either by copying it to Armbian and flashing from there or directly from your host via scp: `scp haos_rockpi-4b-plus-<version>.img root@<armbian ip>:/dev/nvme0n1`
1. Shutdown and insert SD card into your computer
1. Destroy any remaining partitions on the SD card, e.g. using `sgdisk -Z /dev/<whatever>` or by wiping it completely
1. Flash `miniloader.img` to the SD card
1. Insert SD card into board and boot
1. There might be some error messages like `find_valid_gpt: *** ERROR: Invalid GPT ***`. These are expected because U-Boot will attempt to find the boot partition on SD card first (it's not there). It should then recognize the NVMe SSD and boot from it.

## What is supported

### Working hardware

- Serial/UART
- HDMI
- Ethernet
- Wifi
- Bluetooth
- NVMe

### Untested

- Analog Audio
