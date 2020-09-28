#!/bin/bash

# Run get_roms.sh and build_roms.sh first.

if [ "$1" == "" ]; then
    ROM0E=61X8938
    ROM0O=61X8937
    ROM1E=61X8940
    ROM1O=61X8939
else
    ROM0E=$1
    ROM0O=$2
    ROM1E=$3
    ROM1O=$4
fi

CHECK_BAD=".BIN"
if [ "$5" == ".BAD" ]; then
    CHECK_BAD=".BAD"
fi

cd dist/
cmds="$(
printf -- '-n ';
diff <(echo 1; xxd -c 8 $ROM0E"_"$ROM0O"_"*.BIN) <(echo 2;xxd -c 8 $ROM1E"_"$ROM1O"_"*"$CHECK_BAD") | grep '^[0-9]' | sed -e s'/^/-e /' -e s'/c.*$/p/' | tr '\n' ' '
)"

paste -d'|' <(echo -e $ROM0E+$ROM0O'........................'; xxd -c 8 $ROM0E"_"$ROM0O"_"*.BIN) <(echo -e $ROM1E+$ROM1O'........................'; xxd -c 8 $ROM1E"_"$ROM1O"_"*"$CHECK_BAD") | sed $cmds | sed -e s'/  /- /'g | ../bin/romcompare

#cat <<EOD
#          1         2         3         4         5         6         7
#0123456789012345678901234567890123456789012345678901234567890123456789012345678
#EOD
