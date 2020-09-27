#!/usr/bin/env python3

import sys
from functools import partial

asm = 0
if len(sys.argv) > 1 and sys.argv[1] == '--asm':
    asm = 1
if len(sys.argv) > 1 and sys.argv[1] == '--inc':
    asm = 0

if asm:
    print("\
                name    8X8FONT\n\
            \n\
; Typically placed at F000:FA6E - F000:FE6D\n\
            \n\
DGROUP          group   CONST\n\
\n\
CONST           segment para public 'CODE'\n\
\n\
                org     0fa6eh\n\
")

chunk_size = 1
padding_size = 8
xx = []
cc = []
ss = ''
i = 0
while i < padding_size:
    xx.append(-1)
    cc.append('\t')
    ss += '\t'
    i += 1

with open("8X8FONT.BIN", "rb") as f:
    for data in iter(partial(f.read, chunk_size), b''):
        x = int.from_bytes(data, byteorder='big')
        c = chr(x)
        xx.append(x)
        cc.append(c)
        if x >= 32 and x < 127:
            ss += c
        else:
            ss += '\t'
i = 0
while i < padding_size:
    xx.append(-1)
    cc.append(' ')
    i += 1

tabs = '                '

in_bare = 1


i = padding_size
while i < len(xx) - padding_size:
    out_buf = ''
    cur_xx = (i - padding_size) // 8
    cur_cc = chr(cur_xx)
    if cur_xx >= 0 and cur_xx < 32 or cur_xx >= 127:
        descr = 'CHR$({})'.format(cur_xx)
    elif cur_cc == ' ':
        descr = '" " \' (a space)'
    elif cur_cc == '"':
        descr = 'CHR$(34) \' (a " character)'
    elif cur_xx >= 33 and cur_xx < 127:
        descr = '"{}"'.format(cur_cc)
    else:
        descr = 'Unknown character'
    data = ','.join(str(x) for x in xx[i:i + 8])
    spaces = ((len('255,') * 8 + len('db ') + len(' ')) - len(data)) * ' '
    print("{}db {}{}; {}".format(tabs, data, spaces, descr))
    i += 8

if asm:
    print("\
\n\
CONST           ends\n\
\n\
                end\
");
