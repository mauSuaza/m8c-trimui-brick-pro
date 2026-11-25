#!/bin/sh
# M8C launcher for TrimUI Brick Pro (TG4040).
# Works as a stock TrimUI app (SD:/Apps/M8C) and as a NextUI pak
# (SD:/Tools/tg5040/M8C.pak). Everything is relative to this folder.
#
# Pieces:
#   m8c-bin, lib/libSDL3.so.0  - m8c 2.2.3 ARM64 build (myldy20/m8c-trimui-brick-knulli r2)
#   lib/libserialport.so.0     - Debian bullseye arm64 libserialport0 0.1.1-4
#   asoundrc                   - ALSA overrides so SDL3 can find the M8 audio device on stock OS
#
# The stock Brick Pro kernel (4.9.191) has cdc_acm built in, so no driver is bundled.
# If you need one on another firmware, drop a matching cdc-acm.ko into this folder.

APPDIR="$(cd "$(dirname "$0")" && pwd)"
LOG="$APPDIR/log.txt"
cd "$APPDIR" || exit 1

# Log everything so problems can be diagnosed from a Mac afterwards.
exec >"$LOG" 2>&1
echo "M8C Brick Pro launcher"
date
echo "appdir=$APPDIR"
echo "uname=$(uname -a)"
echo "device=${DEVICE:-unset} platform=${PLATFORM:-unset}"
echo

echo "--- framebuffer"
cat /sys/class/graphics/fb0/virtual_size 2>/dev/null
cat /sys/class/graphics/fb0/bits_per_pixel 2>/dev/null
echo "--- input devices"
cat /proc/bus/input/devices 2>/dev/null | grep -E '^(N|H):'
echo "--- sound cards"
cat /proc/asound/cards 2>/dev/null
echo "--- M8 usb audio formats"
for s in /proc/asound/M8/stream0 /proc/asound/card1/stream0; do [ -f "$s" ] && { cat "$s"; break; }; done
echo "--- alsa tools and config"
for t in aplay arecord alsaloop amixer; do echo "$t=$(command -v $t)"; done
ls -la /usr/share/alsa /etc/asound.conf 2>&1 | head -20
grep -n -E 'asoundrc|asound.conf|sysdefault' /usr/share/alsa/alsa.conf 2>/dev/null | head -20
echo "--- etc/asound.conf"
cat /etc/asound.conf 2>/dev/null | head -60
echo "--- aplay -L / arecord -L (with our asoundrc)"
HOME="$APPDIR" aplay -L 2>&1 | head -30
HOME="$APPDIR" arecord -L 2>&1 | head -30
echo

# m8c-only ALSA overrides (ALSA reads $HOME/.asoundrc; HOME is the app folder below).
cp -f "$APPDIR/asoundrc" "$APPDIR/.asoundrc" 2>/dev/null
echo

# USB serial driver for the Teensy (M8 headless shows up as /dev/ttyACM0).
if [ -e /sys/bus/usb/drivers/cdc_acm ]; then
    echo "cdc_acm driver present"
elif [ -f "$APPDIR/cdc-acm.ko" ]; then
    echo "loading bundled cdc-acm.ko"
    insmod "$APPDIR/cdc-acm.ko" && echo "insmod ok" || echo "insmod FAILED"
else
    echo "WARNING: no cdc_acm driver; the Teensy will not appear as /dev/ttyACM0"
fi
sleep 1
echo "--- usb serial devices"
ls -la /dev/ttyACM* 2>&1
chmod 666 /dev/ttyACM* /dev/fb0 2>/dev/null
echo

chmod +x "$APPDIR/m8c-bin" 2>/dev/null

export XDG_CONFIG_HOME="$APPDIR"
export XDG_DATA_HOME="$APPDIR"
export HOME="$APPDIR"
export M8C_CONTROL_PROFILE="face"
export SDL_VIDEODRIVER="offscreen"
export SDL_VIDEO_DRIVER="offscreen"
export SDL_RENDER_DRIVER="software"
export SDL_RENDER_VSYNC="0"
export SDL_AUDIODRIVER="alsa"
export SDL_LOGGING="audio=debug,*=info"
export LD_LIBRARY_PATH="$APPDIR/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

echo "--- starting m8c"
"$APPDIR/m8c-bin"
RESULT=$?
echo "--- m8c exited with status $RESULT"
echo "--- dmesg tail"
dmesg 2>/dev/null | tail -40
sync
exit 0
