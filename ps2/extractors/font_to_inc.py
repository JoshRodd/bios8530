#!/usr/bin/env python3

import sys
from functools import partial

asm = 0
height = 8
bios_seg = 'F000'
vector1 = 'FA6E'
vector2 = 'FE6D'
if len(sys.argv) > 1 and sys.argv[1] == '--asm':
    asm = 1
if len(sys.argv) > 1 and sys.argv[1] == '--inc':
    asm = 0
if len(sys.argv) > 2 and sys.argv[2] == '--16':
    height = 16
    vector1 = '3A30'
    vector2 = '4A2F'
if len(sys.argv) > 2 and sys.argv[2] == '--8':
    vector1 = '4A30'
    vector2 = '512F'

if asm:
    print("\
                name    FONT8X{}\n\
            \n\
; Typically placed at {}:{} - {}:{}\n\
            \n\
BIOS_FONT8X{}{}   segment byte public 'BIOS_ROM'\n\
\n\
                org     0{}h\n\
".format(height,
    bios_seg, vector1, bios_seg, vector2,
    height, '' if height >= 10 else ' ',
    vector1.lower()))

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

with open("FONT8X{}.BIN".format(height), "rb") as f:
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
    cur_xx = (i - padding_size) // height
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
    data = ','.join(str(x) for x in xx[i:i + height])
    spaces = ((len('255,') * height + len('db ') + len(' ')) - len(data)) * ' '
    print("{}db {}{}; {}".format(tabs, data, spaces, descr))
    i += height

if asm:
    print("\
\n\
BIOS_FONT8X{}{}   ends\n\
\n\
                end\
".format(height, '' if height >= 10 else ''));
