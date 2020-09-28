#!/bin/bash

SPLICE="$(pwd)"/../bin/splice

rm -f *_ROM_BASIC.BIN
rm -f *_FONT8X8.BIN
rm -f *_FONT8X16.BIN
rm -f *_FONT8X8V.BIN

# F000:6000-F000:DFFF or # F600:0000-F000:7FFF
for x in ../dist/*.BIN; do
#    "$SPLICE" "$x"; echo
    read a1 a2 a3 x1 a4 x2 a5 x3 a6 x4 a77 < <("$SPLICE" "$x" | tr -d 'h')
    d1=$(printf "ibase=16\n%s\n" "$x1" | bc)
    d2=$(printf "ibase=16\n%s\n" "$x2" | bc)
    d3=$(printf "ibase=16\n%s\n" "$x3" | bc)
    d4=$(printf "ibase=16\n%s\n" "$x4" | bc)
    if [ "$(basename $x)" == "68X1687_68X1627_8530.BIN" ]; then
        dd bs=1 skip=$d1 count=4096 if=$x of="$(basename $x)"_OLDF8X16.BIN 2>/dev/null || exit
    else
        dd bs=1 skip=$d1 count=4096 if=$x of="$(basename $x)"_FONT8X16.BIN 2>/dev/null || exit
    fi
    dd bs=1 skip=$d2 count=2048 if=$x of="$(basename $x)"_FONT8X8V.BIN 2>/dev/null || exit
    dd bs=1 skip=$d3 count=1024 if=$x of="$(basename $x)"_FONT8X8.BIN 2>/dev/null || exit
    dd bs=1 skip=$d4 count=32768 if=$x of="$(basename $x)"_ROM_BASIC.BIN 2>/dev/null || exit
done

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

num=$(openssl dgst -sha256 *_FONT8X8V.BIN | awk '{print $2}' | sort -u | wc -l)
if [ $num != 1 ]; then
    printf "Warning: 8x8 (VGA/MCGA) font images do not match. Check the following list.\n"
    openssl dgst -sha256 *_FONT8X8V.BIN
    exit 1
else
    fname="$(ls *_FONT8X8V.BIN | head -1)"
    mv "$fname" FONT8X8V.BIN || exit
    rm -f *_FONT8X8V.BIN || exit
    printf "8x8 (VGA/MCGA) font in FONT8X8V.BIN\n"
fi

num=$(openssl dgst -sha256 *_FONT8X16.BIN | awk '{print $2}' | sort -u | wc -l)
if [ $num != 1 ]; then
    printf "Warning: 8x16 font images do not match. Check the following list.\n"
    openssl dgst -sha256 *_FONT8X16.BIN
    exit 1
else
    fname="$(ls *_FONT8X16.BIN | head -1)"
    mv "$fname" FONT8X16.BIN || exit
    rm -f *_FONT8X16.BIN || exit
    printf "8x16 font in FONT8X16.BIN\n"
fi

num=$(openssl dgst -sha256 *_OLDF8X16.BIN | awk '{print $2}' | sort -u | wc -l)
if [ $num != 1 ]; then
    printf "Warning: 8x16 font images do not match. Check the following list.\n"
    openssl dgst -sha256 *_OLDF8X16.BIN
    exit 1
else
    fname="$(ls *_OLDF8X16.BIN | head -1)"
    mv "$fname" OLDF8X16.BIN || exit
    rm -f *_OLDF8X16.BIN || exit
    printf "8x16 font in OLDF8X16.BIN\n"
fi

exit 0
