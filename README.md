# Home Assistant OS for Rock Pi 4

This is an unofficial fork of the awesome [Home Assistant Operating System](https://github.com/home-assistant/operating-system) which adds support for the Rock Pi 4 board family.

## Supported boards

- Rock Pi 4A/4A+
- Rock Pi 4B/4B+
- Rock Pi 4C
- Rock 4C+/OKdo Rock 4C+
- Rock 4SE

This build is developed and tested mainly on the Rock Pi 4B+. I am relying on users to test and verify the images on other boards. If you encounter any issues or have a different Rock Pi board which you would like to be supported, please open an issue to get in contact.

## Installation

Download the latest version from the [Releases](https://github.com/citruz/haos-rockpi/releases) page, extract the image and flash it to your SD card or eMMC.

No further configuration should be required.

### Serial output

Contrary to other images for the Rock Pi, the serial baudrate is set to 115200 by default to achieve better compatibility. You can modify the kernel commandline to change the baudrate. Mount the first partition of the image (fat) and edit `commandline.txt`. This can also be done from the booted OS itself by modifying `/mnt/boot/commandline.txt`.

### Device Tree Overlays

A few device tree overlays are supplied with the image to customize the behavior of the board. They can be activated by editing `haos-config.txt` on the boot partition.

- rk3399-disable-wifi-interrupts: The upgrade to Linux 6.1 caused problems on some boards where the wifi chipset would not be initialized correctly. This overlay disables out-of-bounds interrupts for the chipset which fixes the problem. Because it has no known downsides, it is activated by default on all boards.
- rk3399-pcie-gen2: Enable PCIe Gen2 speed.
- rk3399-rock-pi-4-disable-heartbeat: Disable the blue heartbeat led (except Rock 4C+).
- rk3399-pwm-gpio: Enable the PWM pins (11 and 13). Controllable through `/sys/class/pwm/pwmchip[0,1]/`.

Only for Rock 4C+:
- rk3399-rock-4c-plus-disable-hearbeat: Disable the blue heartbeat led.
- rk3399-rock-4c-plus-disable-power-led: Disable the green power led.

On all other boards the green led is hardwired to power, it cannot be turned off.

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

## Automatic updates

Since this is an unofficial fork of Homeassistant OS, the OS image cannot be updated over the air (supervisor, core and all other components can be updated just fine). You will need to reflash for each release.

However, HA's built-in backup and restore functionality works great so there should be no dataloss. Make sure to create a "Full Backup" and download it before flashing a new image.

## Hardware support

### Working hardware

- Serial/UART
- HDMI
- Ethernet
- Wifi
- Bluetooth
- NVMe

### Untested

- Analog Audio
