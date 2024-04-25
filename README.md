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

If using an SD card and a board with builtin eMMC (e.g. 4B+), make sure that there is no other bootloader present in eMMC memory. To do thay you can boot into another working image such as armbian and wipe the eMMC memory with this command (use `lsblk` to make sure that mmcblk0 is the eMMC, not the SD card):

```bash
dd if=/dev/zero of=/dev/mmcblk0 bs=1M count=100
```

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

## Upgrading

Since this is an unofficial fork of Homeassistant OS, the OS image cannot be updated from the UI (supervisor, core and all other components can be updated just fine). Instead, the update process is triggered via SSH from the command line.

**Always create a full backup before upgrading to avoid data loss.**

Use the [HassOS SSH port Configurator](https://community.home-assistant.io/t/add-on-hassos-ssh-port-22222-configurator/264109) to enable ssh root access on port 22222 (the "Terminal & SSH" Add-on will not work as it only exposes a limited shell in a container).

Connect to the device and run the following command. Replace the URL with the appropriate link from the Releases page for your device. Make sure to copy the `.raucb` URL, not the `.img.xz`.

```
rauc install https://github.com/citruz/haos-rockpi/releases/download/<release>/haos_<device>-<release>.raucb
```

The file will be downloaded to a temporary location in `/mnt/data/tmp/` so make sure that there is enough space on the data partition left.

```
# rauc install https://github.com/citruz/haos-rockpi/releases/download/ota-test/haos_rockpi-4b-plus-12.2.dev20240502.raucb
installing
  0% Installing
  0% Determining slot states
 10% Determining slot states done.
 10% Checking bundle
 10% Verifying signature
 20% Verifying signature done.
 20% Checking bundle done.
 20% Checking manifest contents
 30% Checking manifest contents done.
 30% Determining target install group
 40% Determining target install group done.
 40% Updating slots
 40% Checking slot boot.0
 41% Checking slot boot.0 done.
 41% Copying image to boot.0
 ...
 99% Copying image to spl.0 done.
 99% Updating slots done.
100% Installing done.
Installing `https://github.com/citruz/haos-rockpi/releases/download/ota-test/haos_rockpi-4b-plus-12.2.dev20240502.raucb` succeeded
```

Now reboot the device to switch to the new OS version.

This process also updates the bootloader. If it detects that the system is booted from an SSD it will update the bootloader on the eMMC or SD card.

If there is an error during installation, run `journalctl -u rauc.service` to get an extended output log.

**Note:** The OTA update functionality was added in 12.3. To upgrade from an earlier version to 12.3 or later a few extra steps are required. Please refer to the the 12.3 release notes for detailed instructions.


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
