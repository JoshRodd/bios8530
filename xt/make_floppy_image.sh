#!/bin/bash

PCJS_DIR="$HOME"/src/pcjs.org
DISKIMAGE="$PCJS_DIR"/tools/modules/diskimage.js
DOSFSCK=/usr/local/sbin/dosfsck
FLOPPYBASE="$(pwd)"/floppybase
BUILD_DIR="$(pwd)"/build
FLOPPY_A="$BUILD_DIR"/floppya
FLOPPY_B="$BUILD_DIR"/floppyb
FLOPPY_A_BIN="$FLOPPY_A".bin
FLOPPY_B_BIN="$FLOPPY_B".bin
ARCHIVES_DIR="$(pwd)"/archives
MACHINE="$BUILD_DIR"/machine.json

if [ ! -f "$DISKIMAGE" ]; then
    printf "pcjs.org required to be installed in %s\n" "$PCJS_DIR" >&2; exit 1; fi

if [ ! -f "$DOSFSCK" ]; then
    printf "dosfstools required; run brew install dosfstools" >&2; exit 1; fi

mkdir -p "$BUILD_DIR" || exit
rm -f "$FLOPPY_B".img || exit
rm -f ~/.mtoolsrc || exit
cat >~/.mtoolsrc <<EOD
drive a:
  file="$FLOPPY_A_BIN"
drive b:
  file="$FLOPPY_B_BIN"
EOD
cp "$ARCHIVES_DIR"/PCDOS330-DISK1.img "$FLOPPY_A_BIN" || exit
dd if=/dev/zero of="$FLOPPY_B_BIN" bs=512 count=720 || exit
printf 'B:\r\nDEBUG COLDBOOT.COM\r\n' > "$BUILD_DIR"/autoexec.bat || exit
mcopy "$BUILD_DIR"/autoexec.bat a:AUTOEXEC.BAT || exit
mformat -t 40 -h 2 -n 9 b: || exit
mcopy "$FLOPPYBASE"/* b: || exit
mcopy "$BUILD_DIR"/coldboot.com b:COLDBOOT.COM || exit
mcopy "$BUILD_DIR"/hello.com b:HELLO.COM || exit
"$DOSFSCK" "$FLOPPY_A_BIN" || exit
"$DOSFSCK" "$FLOPPY_B_BIN" || exit
rm -f "$FLOPPY_A".json || exit
rm -f "$FLOPPY_B".json || exit
node "$PCJS_DIR"/tools/modules/diskimage.js "$FLOPPY_A_BIN" "$FLOPPY_A".json
node "$PCJS_DIR"/tools/modules/diskimage.js "$FLOPPY_B_BIN" "$FLOPPY_B".json

cat >"$MACHINE" <<EOD
---
layout: page
title: AutoBuild
permalink: /software/pcx86/autobuild/
redirect_from: /disks/pcx86/autobuild/
machines:
  - id: ibm5150
    type: pcx86
    config: /configs/pcx86/machine/autobuild/machine.json
    sizeRAM: 256
    testRAM: false
    autoMount:
      A:
        name: PC DOS 2.00 (Disk 1)
      B:
        name: PC DOS 2.00 (Disk 2)
    autoType: $date\\r$time\\rB:\\r
EOD

mkdir -p "$PCJS_DIR"/
