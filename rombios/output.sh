#!/bin/bash

make >/dev/null 2>&1
./print_diff.sh|bin/romcompare|sed s';\[/b\]\[/u\]\[u\]\[b\];;'g|pbcopy
