#!/bin/bash

# Run get_roms.sh and build_roms.sh first.

if [ "$1" == "--standout" ]; then
    romcompare_opts="$1"
    shift
fi

CHECK_BAD=".BIN"
if [ "$5" == ".BAD" ]; then
    CHECK_BAD=".BAD"
fi

if [ "$1" == "" ]; then
    ROM0E=61X8938
    ROM0O=61X8937
    ROM1E=61X8940
    ROM1O=61X8939
    ROM0=$ROM0E"_"$ROM0O"_"*.BIN
    ROM1=$ROM1E"_"$ROM1O"_"*"$CHECK_BAD"
    cd dist/
else
    if [ "$3" == "" ]; then
        ROM0="$1"
        ROM1="$2"
        ROM0E="Even"
        ROM0O="Odd"
        ROM1E="Even"
        ROM1O="Odd"
    else
        ROM0E=$1
        ROM0O=$2
        ROM1E=$3
        ROM1O=$4
        ROM0=$ROM0E"_"$ROM0O"_"*.BIN
        ROM1=$ROM1E"_"$ROM1O"_"*"$CHECK_BAD"
        cd dist/
    fi
fi

cmds="$(
printf -- '-n ';
diff <(echo 1; xxd -c 8 $ROM0) <(echo 2;xxd -c 8 $ROM1) | grep '^[0-9]' | sed -e s'/^/-e /' -e s'/c.*$/p/' | tr '\n' ' '
)"

paste -d'|' <(echo -e $ROM0E+$ROM0O'........................'; xxd -c 8 $ROM0) <(echo -e $ROM1E+$ROM1O'........................'; xxd -c 8 $ROM1) | sed $cmds | sed -e s'/  /- /'g | ../bin/romcompare $romcompare_opts

#cat <<EOD
#          1         2         3         4         5         6         7
#0123456789012345678901234567890123456789012345678901234567890123456789012345678
#EOD
