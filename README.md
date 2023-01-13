# Home Assistant OS for Rock Pi 4B+

This is an unofficial fork of the awesome [Home Assistant Operating System](https://github.com/home-assistant/operating-system) which adds support for the Rock Pi 4B+ board.

## Installation

Download the latest version from the [Releases](https://github.com/citruz/haos-rockpi/releases) page and flash it to your SD card or eMMC.

No further configuration should be required.

### Serial configuration

The serial baud rate is set to 1500000 as it is the default for the Rock Pi. If your serial interface cannot handle that speed, you can modify the kernel commandline to change it. To do this, mount the first partition of the image (fat) and modify `commandline.txt`.

### Working hardware

- Serial/UART
- HDMI
- Ethernet
- Wifi
- Bluetooth

### Untested

- NVMe
- Analog Audio

## Other boards

You have a different Rock Pi board and would like to run Home Assistant on it? Please open an issue to get in contact.
