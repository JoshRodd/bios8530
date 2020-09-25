#!/bin/bash

SRC_DIR="$(pwd)"/
BUILD_DIR="$(pwd)"/build/

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

while read model even odd; do
    printf "Retrieving ROMs %s and %s for model %s...\n" "$even" "$odd" "$model"
    for file in "$even" "$odd"; do
        curl -O http://ibmmuseum.com/BIOS/"$model"/"$file".BIN || exit
    done
done < <(cat "$SRC_DIR"romlist.txt | sed '/^#/'d)
printf "Finished\n"
