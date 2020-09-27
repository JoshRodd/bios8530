#!/bin/bash

./extract.sh || exit

./to_inc.py --asm > ROMBASIC.ASM || exit
./font_to_inc.py --asm > FONT8X8.ASM || exit
./font_to_inc.py --asm --16 > FONT8X16.ASM || exit

uasm -bin -Fo=ROMBASIC.BINTEST ROMBASIC.ASM || exit
uasm -bin -Fo=FONT8X8.BINTEST FONT8X8.ASM || exit
uasm -bin -Fo=FONT8X16.BINTEST FONT8X16.ASM || exit

num=$(openssl dgst -sha256 ROMBASIC.BINTEST ROMBASIC.BIN | awk '{print $2}' | sort -u | wc -l)
if [ $num != 1 ]; then
    printf "Warning: ROM BASIC images do not match. Check the following list.\n"
    openssl dgst -sha256 ROMBASIC.BINTEST ROMBASIC.BIN
    exit 1
else
    rm -f ROMBASIC.BINTEST ROMBASIC.BIN
    printf "ROMBASIC.ASM checks valid - produces same image as ROMBASIC.BIN\n"
fi

num=$(openssl dgst -sha256 FONT8X8.BINTEST FONT8X8.BIN | awk '{print $2}' | sort -u | wc -l)
if [ $num != 1 ]; then
    printf "Warning: 8x8 font images do not match. Check the following list.\n"
    openssl dgst -sha256 FONT8X8.BINTEST FONT8X8.BIN
    exit 1
else
    rm -f FONT8X8.BINTEST FONT8X8.BIN
    printf "FONT8X8.ASM checks valid - produces same image as FONT8X8.BIN\n"
fi

num=$(openssl dgst -sha256 FONT8X16.BINTEST FONT8X16.BIN | awk '{print $2}' | sort -u | wc -l)
if [ $num != 1 ]; then
    printf "Warning: 8x16 font images do not match. Check the following list.\n"
    openssl dgst -sha256 FONT8X16.BINTEST FONT8X16.BIN
    exit 1
else
    rm -f FONT8X16.BINTEST FONT8X16.BIN
    printf "FONT8X16.ASM checks valid - produces same image as FONT8X16.BIN\n"
fi

num=$(openssl dgst -sha256 FONT8X8V.BINTEST FONT8X8V.BIN | awk '{print $2}' | sort -u | wc -l)
if [ $num != 1 ]; then
    printf "Warning: 8x8 (VGA/MCGA) font images do not match. Check the following list.\n"
    openssl dgst -sha256 FONT8X8V.BINTEST FONT8X8V.BIN
    exit 1
else
    rm -f FONT8X8V.BINTEST FONT8X8V.BIN
    printf "FONT8X8V.ASM checks valid - produces same image as FONT8X8V.BIN\n"
fi

exit 0
