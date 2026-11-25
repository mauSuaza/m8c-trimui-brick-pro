# m8c for TrimUI Brick Pro (stock OS)

Run a **Dirtywave M8 Headless** (Teensy 4.1) on the **TrimUI Brick Pro (TG4040)** with
picture, controls and sound, as a plain app on the **stock TrimUI OS**. No custom firmware needed.

Why this exists: as of November 2026 the Brick Pro isn't supported by Knulli's public builds (the
Brick image shows white stripes on the Pro's screen), the NextUI M8C pak is gone, and PortMaster
has no m8c. The stock OS drives the screen fine, so this packages m8c as a stock app.

## What you need

- TrimUI Brick Pro on stock firmware (tested on kernel `4.9.191`, Aug 2026 build)
- Teensy 4.1 flashed with [M8 Headless firmware](https://github.com/Dirtywave/M8HeadlessFirmware)
  (tested with 6.6.4A), with a FAT32 micro SD card in the Teensy
- A micro USB to USB-C **data** cable (charge-only cables won't work)
- A FAT32 micro SD card for the Brick Pro

## Install

1. Download `M8C-brickpro.zip` from [Releases](../../releases) (or clone this repo).
2. Copy the `Apps/M8C` folder to the Brick Pro's SD card so you end up with `SD:/Apps/M8C/launch.sh`.
3. Put the card in the Brick Pro and turn it on.
4. Plug the Teensy into the Brick Pro's **top** USB-C port. The bottom port doesn't work for this.
5. Open **Apps → M8C**.

## Controls

| Brick Pro | M8 |
|---|---|
| D-pad | Arrows |
| A | PLAY |
| B | SHIFT |
| X | EDIT |
| Y | OPTION |
| Select + B | Quit m8c |

Your songs are saved on the Teensy's SD card, not on the Brick.

## Known limitations

- **Sleep breaks the connection.** If the Brick Pro goes to sleep while m8c is running, the Teensy
  isn't recognized right away after waking and the M8 display glitches. Unsaved work can be lost.
  - **Save often** (Project view → SAVE). Songs live on the Teensy's SD card, not the Brick's.
  - Turn off or lengthen the Brick's auto-sleep in the stock Settings before long sessions.
  - If it happens: quit m8c (Select + B) and **restart the Brick**, then relaunch M8C. If the
    Teensy still isn't detected, unplug and replug it as well.

## How it works

- **m8c 2.2.3** ARM64 build with SDL 3.2.20 and the Brick framebuffer/controls bridge from
  [myldy20/m8c-trimui-brick-knulli](https://github.com/myldy20/m8c-trimui-brick-knulli) (r2),
  originally made for Knulli on the original Brick. It runs unmodified on the Brick Pro's stock OS.
- **libserialport** (`lib/libserialport.so.0`) isn't on the stock OS, so it's bundled from Debian
  bullseye arm64 (`libserialport0 0.1.1-4`, unmodified).
- **USB serial**: the stock kernel has `cdc_acm` built in, so the Teensy shows up as `/dev/ttyACM0`.
- **Audio fix**: the stock ALSA config defines `sysdefault` without a `CARD` argument, so SDL3 can't
  open `sysdefault:N` to list cards and never finds the M8's USB audio. `asoundrc` overrides
  `ctl.sysdefault`/`pcm.sysdefault` for the m8c process only (`launch.sh` sets `HOME` to the app
  folder and copies it to `.asoundrc`). System audio isn't touched.

## Troubleshooting

`launch.sh` writes `Apps/M8C/log.txt` every run: screen size, input devices, sound cards, the M8's
USB audio formats, ALSA devices, and m8c's own output. Put the card in a computer and read it.

- `Found M8 in /dev/ttyACM0` missing → try the other USB-C port or another data cable.
- `Cannot find M8 recording device` → audio fix didn't apply; open an issue with your `log.txt`.
  Remove your Wi-Fi MAC address from the log first if you care about that.

## Credits and licenses

- [m8c](https://github.com/laamaa/m8c) by Jonne Kokkonen, MIT (`LICENSE-m8c`)
- Brick port by [myldy20](https://github.com/myldy20/m8c-trimui-brick-knulli), MIT (`LICENSE-m8c-brick-port.txt`)
- [SDL3](https://libsdl.org), zlib license (`LICENSE-SDL.txt`)
- [libserialport](https://sigrok.org/wiki/Libserialport), LGPL-3.0+ (`LICENSE-libserialport.txt`).
  Unmodified binary from Debian; source: <https://sources.debian.org/src/libserialport/0.1.1-4/>
- M8 and M8 Headless firmware © Dirtywave. Not included here; get it from Dirtywave.
- Launcher, ALSA fix and packaging in this repo: MIT (`LICENSE`)

Not affiliated with Dirtywave or TrimUI.
