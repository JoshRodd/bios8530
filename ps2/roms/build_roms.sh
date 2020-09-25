#!/bin/bash

export PATH=$PATH:"$(pwd)"/../src

fileext=.BIN

while read even odd; do
    even="$(basename "$even" "$fileext")"
    odd="$(basename "$odd" "$fileext")"
    echo
    echo $even $odd:
    splice --verbose "$even""$fileext" "$odd""$fileext" "$even"_"$odd""$fileext"
    echo
done < <(cat <<EOD
00F2122 00F2123
33F4498 33F4499
61X8938_BAD 61X8937
61X8940 61X8939
68X1687 68X1627
EOD)
