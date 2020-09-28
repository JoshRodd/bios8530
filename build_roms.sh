#!/bin/bash

BIN_DIR="$(pwd)"/bin
SPLICE=$(pwd)/bin/splice
BASE_DIR="$(pwd)"/
BUILD_DIR="$(pwd)"/build/
DIST_DIR="$(pwd)"/dist/
ARCHIVES_DIR="$(pwd)"/archives/

fileext=.BIN

mkdir -p "$BUILD_DIR" || exit
mkdir -p "$DIST_DIR" || exit
cd "$BUILD_DIR"
if [ ! -f 00F2123.BIN ]; then
    printf "Run ./get_roms.sh first." >&2
    exit 1
fi
rm -f 61X8938.BIN || exit
rm -f 61X8938.BAD || exit
rm -f 61X8937.BIN || exit
rm -f IBM_PS2-30/61X8937_A58470_IBM87.bin || exit
rm -f IBM_PS2-30/61X8938_A58470_IBM87.bin || exit
rm -f 61X8938_A58470_IBM87nwe26sept2020 || exit
rmdir IBM_PS2-30 2>/dev/null
unzip -q "$ARCHIVES_DIR"IBM_PS2-30.zip || exit
mv IBM_PS2-30/61X8938_A58470_IBM87.bin 61X8938.BAD || exit # This is a known bad file.
mv IBM_PS2-30/61X8937_A58470_IBM87.bin 61X8937.BIN || exit
unzip -q "$ARCHIVES_DIR"61X8938_A58470_IBM87nwe26sept2020.zip || exit
mv 61X8938_A58470_IBM87nwe26sept2020 61X8938.BIN || exit # This is a replacement good file.
cp "$ARCHIVES_DIR"00F2122.BAD 00F2122.BAD || exit
cp "$ARCHIVES_DIR"00F2122.BIN 00F2122.BIN || exit
rmdir IBM_PS2-30 || exit

printf "\n%s\n" '   Filenames      ROM    Model                Font vectors        ROM BASIC      BIOS    Copy-   Part numbers  '
printf   "%s\n" '  Even    Odd     Date               8x16    8x8 (VGA/MCGA)   8x8   vector    revision  rights   Even     Odd  '
while read model even odd; do
    even="$(basename "$even" "$fileext")"
    odd="$(basename "$odd" "$fileext")"
    printf "%s %s: " "$even" "$odd"
    output="$("$SPLICE" --verbose "$BUILD_DIR""$even""$fileext" "$BUILD_DIR""$odd""$fileext" "$BUILD_DIR""$even"_"$odd"_"$model""$fileext")"
    if [ "$?" == 0 ]; then mv "$BUILD_DIR""$even"_"$odd"_"$model""$fileext" "$DIST_DIR"; fi
    printf "%s" "$output"
    read romdate ibmmodel a1 vector8x16 a2 vector8x8v a3 vector8x8 a4 basicvector copyright copyrightend a5 revision evenpn oddpn < <(printf "%s\n" "$output")
    if [ "$model" != "$ibmmodel" ]; then printf " Model mismatch"; fi
    if [ "$evenpn" != "$even" -a "$oddpn" != "$odd" ]; then printf " Part number mismatch";
    else
        if [ "$evenpn" != "$even" ]; then printf " Even part number mismatch"; fi
        if [ "$oddpn" != "$odd" ]; then printf " Odd part number mismatch"; fi
    fi
    printf "\n"
done < <(cat "$BASE_DIR"romlist.txt | sed '/^#/'d)

#model=8525
#even=00F2122
#odd=00F2123
#echo
#echo -n $model BAD from $even and $odd:' '
#"$SPLICE" --verbose "$BUILD_DIR""$even".BAD "$BUILD_DIR""$odd""$fileext" "$BUILD_DIR""$even"_"$odd"_"$model".BAD
#mv "$BUILD_DIR""$even"_"$odd"_"$model".BAD "$DIST_DIR"

echo
