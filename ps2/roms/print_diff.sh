#!/bin/bash

# Run get_roms.sh and build_roms.sh first.

cd dist/
cmds="$(
printf -- '-n ';
diff <(echo 1; xxd -c 8 61X8938_61X8937_8530_0.BIN) <(echo 2;xxd -c 8 61X8940_61X8939_8530_0.BIN) | grep '^[0-9]' | sed -e s'/^/-e /' -e s'/c.*$/p/' | tr '\n' ' '
)"

paste <(echo -e Bad ROM'\t\t\t\t'; xxd -c 8 61X8938_61X8937_8530_0.BIN) <(echo -e Comparison ROM'\t\t\t'; xxd -c 8 61X8940_61X8939_8530_0.BIN) <(echo Good ROM; xxd -c 8 61X8940_61X8939_8530.BIN) | sed $cmds
