#!/bin/bash

BASE_DIR="$(pwd)"/
BUILD_DIR="$(pwd)"/build/
ARCHIVES_DIR="$(pwd)"/archives/

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

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
        if [ $url == "" ]; then
            url=http://www.vcfed.org/forum/showthread.php?76874-PS-2-Model-30-8086-BIOS-dump"$suffix"
        fi
        cat <<EOD
Retrieve $filename from:
$url
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
check_file 00F2122.BIN 944e24a2b5d158576dbe007dd37b26f950a4e1d134bced770332a884ffa3f055 32768 "" http://www.mediafire.com/file/j0bh15f4gnbky4a/file

while read model even odd; do
    for file in "$even" "$odd"; do
        if [ -f "$file".BIN ]; then
            need_file=0
        else
            need_file=1
        fi
        if [ "$need_file" == "1" -a "$file" != 61X8938 -a "$file" != 61X8937 -a "$file" != 00F2122 ]; then
            printf "Retrieving ROM %s for model %s...\n" "$file" "$model"
            curl -O http://ibmmuseum.com/BIOS/"$model"/"$file".BIN || exit
            need_file=0
        fi
        if [ "$need_file" == "0" ]; then
            sha="$(openssl dgst -sha256 "$file".BIN)"
            entry="$(grep "^SHA256($file.BIN)= [0-9a-f][0-9a-f]*$" "$BASE_DIR"romlist_sha.txt)"
            if [ "$sha" == "$entry" ]; then
                printf "$file is good\n"
                need_file=0
            else
                printf "The file $BUILD_DIR$file.BIN is corrupt. Please delete it.\n" >&2
                exit 1
            fi
        fi
    done
done < <(cat "$BASE_DIR"romlist.txt | sed '/^#/'d)
