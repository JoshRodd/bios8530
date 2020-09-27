#!/bin/bash

rm -f *_ROM_BASIC.BIN

# F000:6000-F000:DFFF or
# F600:0000-F000:7FFF
for x in ../dist/*.BIN; do dd bs=1 skip=24576 count=32768 if=$x of="$(basename $x)"_ROM_BASIC.BIN; done 2>/dev/null

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
    exit 0
fi
