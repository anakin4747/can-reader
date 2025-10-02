
# Wi-Fi Enabled CAN Bus Reader Project on an ESP32 with Zephyr

Containerized Zephyr Setup for ESP32 WROOM32

[ESP32 DevKitC WROOM Documentation](https://docs.zephyrproject.org/3.7.0/boards/espressif/esp32_devkitc_wroom/doc/index.html)

## Initial setup

This is containerized using [cqfd](https://github.com/savoirfairelinux/cqfd),
which is essentially a wrapper around `docker` that mounts this directory inside
a container at the same path inside the container.

So you should have `docker` installed, `docker` group permissions for your
user, and a `docker` service running on it.

First build the docker image from the dockerfile in `.cqfd/docker/Dockerfile`
with the following command:

```sh
cqfd init
```

Then setup everything, build and flash with:

```sh
cqfd
```

This will run the `command` in `.cqfdrc` inside a docker container from the
newly generated docker image.

The `scripts/initial-setup.sh` will download all the Zephyr dependencies (which
takes forever btw), build the application in `app`, and then flash
`/dev/ttyUSB0`.

To test the demo application use an application like `screen`, `putty`,
`picocom`, etc to view the `/dev/ttyUSB0` device:

```sh
screen /dev/ttyUSB0 115200
```

Then click the reset button on the board to see that it boots:

```
...
rst:0x1 (POWERON_RESET),boot:0x13 (SPI_FAST_FLASH_BOOT)
configsip: 0, SPIWP:0xee
clk_drv:0x00,q_drv:0x00,d_drv:0x00,cs0_drv:0x00,hd_drv:0x00,wp_drv:0x00
mode:DIO, clock div:2
load:0x3ffb0000,len:15892
load:0x40080000,len:63024
1150 mmu set 00010000, pos 00010000
entry 0x40089680
I (48) soc_init: ESP Simple boot
I (48) soc_init: compile time Oct  2 2025 13:09:45
W (48) soc_init: Unicore bootloader
I (48) soc_init: chip revision: v3.0
I (51) flash_init: SPI Speed      : 40MHz
I (55) flash_init: SPI Mode       : DIO
I (59) flash_init: SPI Flash Size : 4MB
I (62) boot: DRAM       : lma=00001020h vma=3ffb0000h size=03e14h ( 15892)
I (68) boot: IRAM       : lma=00004e3ch vma=40080000h size=0f630h ( 63024)
I (74) boot: IROM       : lma=00020000h vma=400d0000h size=626bch (403132)
I (80) boot: DROM       : lma=00090000h vma=3f400000h size=17384h ( 95108)
I (98) boot: libc heap size 107 kB.
I (98) spi_flash: detected chip: generic
I (98) spi_flash: flash io: dio

*** Booting Zephyr OS build 9ee617a8ee30 ***
uart:~$
```

Now run `wifi scan` to search for wifi networks:

```sh
uart:~$ wifi scan
```
