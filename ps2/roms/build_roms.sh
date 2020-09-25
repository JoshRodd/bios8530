#!/bin/bash

export PATH=$PATH:"$(pwd)"/../src
BUILD_DIR="$(pwd)"/build/

fileext=.BIN

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"
rm -f IBM_PS2-30/61X8937_A58470_IBM87.bin
rm -f IBM_PS2-30/61X8938_A58470_IBM87.bin
rmdir IBM_PS2-30 2>/dev/null
unzip ../archives/IBM_PS2-30.zip || exit
mv IBM_PS2-30/61X8937_A58470_IBM87.bin 61X8937.BIN || exit
mv IBM_PS2-30/61X8938_A58470_IBM87.bin 61X8938.BIN || exit # This is a known bad file.
rmdir IBM_PS2-30 || exit

while read even odd; do
    even="$(basename "$even" "$fileext")"
    odd="$(basename "$odd" "$fileext")"
    echo
    echo $even $odd:
    splice --verbose "$even""$fileext" "$odd""$fileext" "$BUILD_DIR""$even"_"$odd""$fileext"
    echo
done < <(cat <<EOD
00F2122 00F2123
33F4498 33F4499
61X8938 61X8937
61X8940 61X8939
68X1687 68X1627
EOD)
