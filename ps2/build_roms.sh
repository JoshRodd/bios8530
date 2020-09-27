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
unzip "$ARCHIVES_DIR"IBM_PS2-30.zip || exit
mv IBM_PS2-30/61X8938_A58470_IBM87.bin 61X8938.BAD || exit # This is a known bad file.
mv IBM_PS2-30/61X8937_A58470_IBM87.bin 61X8937.BIN || exit
unzip "$ARCHIVES_DIR"61X8938_A58470_IBM87nwe26sept2020.zip || exit
mv 61X8938_A58470_IBM87nwe26sept2020 61X8938.BIN || exit # This is a replacement good file.
cp "$ARCHIVES_DIR"00F2122.BAD 00F2122.BAD || exit
cp "$ARCHIVES_DIR"00F2122.BIN 00F2122.BIN || exit
rmdir IBM_PS2-30 || exit

while read model even odd; do
    even="$(basename "$even" "$fileext")"
    odd="$(basename "$odd" "$fileext")"
    echo
    echo -n $model ROM from $even and $odd:' '
    "$SPLICE" --verbose "$BUILD_DIR""$even""$fileext" "$BUILD_DIR""$odd""$fileext" "$BUILD_DIR""$even"_"$odd"_"$model""$fileext"
    if [ "$?" == 0 ]; then mv "$BUILD_DIR""$even"_"$odd"_"$model""$fileext" "$DIST_DIR"; fi
done < <(cat "$BASE_DIR"romlist.txt | sed '/^#/'d)

#model=8525
#even=00F2122
#odd=00F2123
#echo
#echo -n $model BAD from $even and $odd:' '
#"$SPLICE" --verbose "$BUILD_DIR""$even".BAD "$BUILD_DIR""$odd""$fileext" "$BUILD_DIR""$even"_"$odd"_"$model".BAD
#mv "$BUILD_DIR""$even"_"$odd"_"$model".BAD "$DIST_DIR"

echo
