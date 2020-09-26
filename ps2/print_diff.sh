#!/bin/bash

# Run get_roms.sh and build_roms.sh first.

ROM0E=61X8938
ROM0O=61X8937
ROM1E=61X8940
ROM1O=61X8939

cd dist/
cmds="$(
printf -- '-n ';
diff <(echo 1; xxd -c 8 $ROM0E"_"$ROM0O"_"8530.BIN) <(echo 2;xxd -c 8 $ROM1E"_"$ROM1O"_"8530.BIN) | grep '^[0-9]' | sed -e s'/^/-e /' -e s'/c.*$/p/' | tr '\n' ' '
)"

paste -d'|' <(echo -e $ROM0E+$ROM0O'........................'; xxd -c 8 $ROM0E"_"$ROM0O"_"8530.BIN) <(echo -e $ROM1E+$ROM1O'........................'; xxd -c 8 $ROM1E"_"$ROM1O"_"8530.BIN) | sed $cmds | sed -e s'/  /- /'g

#cd dist/
#cmds="$(
#printf -- '-n ';
#diff <(echo 1; xxd -c 8 $ROM0E_$ROM0O_8530_0.BIN) <(echo 2;xxd -c 8 $ROM1E_$ROM1O_8530_0.BIN) | grep '^[0-9]' | sed -e s'/^/-e /' -e s'/c.*$/p/' | tr '\n' ' '
#)"
#
#paste <(echo -e Bad ROM'\t\t\t\t'; xxd -c 8 $ROM0E_$ROM0O_8530_0.BIN) <(echo -e Comparison ROM'\t\t\t'; xxd -c 8 $ROM1E_$ROM1O_8530_0.BIN) <(echo Good ROM; xxd -c 8 $ROM1E_$ROM1O_8530.BIN) | sed $cmds

cat <<EOD
          1         2         3         4         5         6         7
0123456789012345678901234567890123456789012345678901234567890123456789012345678
EOD
