#!/bin/bash

rm -f *_ROM_BASIC.BIN
rm -f *_FONT8X8.BIN
rm -f *_FONT8X16.BIN

# F000:6000-F000:DFFF or # F600:0000-F000:7FFF
for x in ../dist/*.BIN; do dd bs=1 skip=24576 count=32768 if=$x of="$(basename $x)"_ROM_BASIC.BIN; done 2>/dev/null
for x in ../dist/*.BIN; do dd bs=1 skip=64110 count=1024 if=$x of="$(basename $x)"_FONT8X8.BIN; done 2>/dev/null
for x in ../dist/61X8938*.BIN; do dd bs=1 skip=14896 count=4096 if=$x of="$(basename $x)"_FONT8X16.BIN; done 2>/dev/null
# Full 8x8 font is at 18992 X 2048 bytes

num=$(openssl dgst -sha256 *_ROM_BASIC.BIN | awk '{print $2}' | sort -u | wc -l)
if [ $num != 1 ]; then
    printf "Warning: ROM BASIC images do not match. Check the following list.\n"
    openssl dgst -sha256 *_ROM_BASIC.BIN
    exit 1
else
    fname="$(ls *_ROM_BASIC.BIN | head -1)"
    mv "$fname" ROMBASIC.BIN || exit
    rm -f *_ROM_BASIC.BIN || exit
    printf "BASIC in ROMBASIC.BIN\n"
fi

num=$(openssl dgst -sha256 *_FONT8X8.BIN | awk '{print $2}' | sort -u | wc -l)
if [ $num != 1 ]; then
    printf "Warning: 8x8 font images do not match. Check the following list.\n"
    openssl dgst -sha256 *_FONT8X8.BIN
    exit 1
else
    fname="$(ls *_FONT8X8.BIN | head -1)"
    mv "$fname" FONT8X8.BIN || exit
    rm -f *_FONT8X8.BIN || exit
    printf "8x8 font in FONT8X8.BIN\n"
fi

num=$(openssl dgst -sha256 *_FONT8X16.BIN | awk '{print $2}' | sort -u | wc -l)
if [ $num != 1 ]; then
    printf "Warning: 8x8 font images do not match. Check the following list.\n"
    openssl dgst -sha256 *_FONT8X16.BIN
    exit 1
else
    fname="$(ls *_FONT8X16.BIN | head -1)"
    mv "$fname" FONT8X16.BIN || exit
    rm -f *_FONT8X16.BIN || exit
    printf "8x8 font in FONT8X16.BIN\n"
fi

exit 0
