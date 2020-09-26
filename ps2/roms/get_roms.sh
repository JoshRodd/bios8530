#!/bin/bash

BASE_DIR="$(pwd)"/
BUILD_DIR="$(pwd)"/build/
ARCHIVES_DIR="$(pwd)"/archives/

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

while read model even odd; do
    printf "Retrieving ROMs %s and %s for model %s...\n" "$even" "$odd" "$model"
    for file in "$even" "$odd"; do
        curl -O http://ibmmuseum.com/BIOS/"$model"/"$file".BIN || exit
    done
done < <(cat "$BASE_DIR"romlist.txt | sed '/^#/'d)
filename=61X8938_A58470_IBM87nwe26sept2020.zip
shasum=1424a92ce030e512d1defad653a2b590ef4391b1f93ef3b0bfb20dc4dddf98a1
filesize=26061
suffix="/page2"

function check_file {
    filename="$1"
    shift
    shasum="$1"
    shift
    filesize="$1"
    shift
    suffix="$1"
    shift

    if [ ! -f "$ARCHIVES_DIR""$filename" ]; then
        cat <<EOD
Retrieve $filename from:
http://www.vcfed.org/forum/showthread.php?76874-PS-2-Model-30-8086-BIOS-dump"$suffix"
File size: $filesize bytes
SHA256: $shasum
Place it into "$ARCHIVES_DIR"

EOD
    else
        if [ "$(openssl dgst -sha256 "$ARCHIVES_DIR""$filename")" != "SHA256($ARCHIVES_DIR$filename)= $shasum" ]; then
            printf "The file $ARCHIVES_DIR$filename is corrupt. Please delete it.\n" >&2
            if [ "$DEBUG" ]; then
                printf "%s\n%s\n" "$(openssl dgst -sha256 "$ARCHIVES_DIR""$filename")" "SHA256($ARCHIVES_DIR$filename)= $shasum"
            fi
        else
            printf "$filename is good\n"
        fi
    fi
}

check_file 61X8938_A58470_IBM87nwe26sept2020.zip 1424a92ce030e512d1defad653a2b590ef4391b1f93ef3b0bfb20dc4dddf98a1 26061 /page2
check_file IBM_PS2-30.ZIP 453d9b82fb39d40f5dc41fc450083154b1dca86affa9a036824cba9f252b7ead 49324
