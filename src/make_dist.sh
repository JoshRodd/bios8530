#!/bin/bash

OPWD="$(pwd)"
for x in "$@"; do cp $x ../dist/$(printf "$x\n" | tr a-z A-Z) || exit; done || exit
cd ../dist
rm -f HOWARD.ZIP || exit
echo "$PWD"
openssl dgst -sha256 $(ls | sort) > "$OPWD"/checksums_dist.txt
zip HOWARD.ZIP --DOS-names -9 "$@" || exit
cd "$OPWD"
comm -13 checksums_3.6.1.txt checksums_dist.txt > dist_changed_files.txt || exit
if [ -s dist_changed_files.txt ]; then
        printf "Distribution does not match 3.6.1.\nSee dist_changed_files.txt for discrepancies.\n"
        exit 1
else
        rm dist_changed_files.txt
        rm checksums_dist.txt
fi
