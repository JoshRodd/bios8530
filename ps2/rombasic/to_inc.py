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
                name    ROMBASIC\n\
            \n\
DGROUP          group   _TEXT\n\
\n\
_TEXT           segment para public 'CODE'\n\
                assume cs:_TEXT,ds:nothing,es:nothing,ss:nothing\n\
\n\
                org     0\n\
\n\
_main           proc    far\n\
_main           endp\n\
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

with open("ROMBASIC.BIN", "rb") as f:
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
    while (xx[i] >= 32 and xx[i] < 127):
        if ss[i:][:4] == 'PQRS':
            break
        if cc[i] == "'":
            if out_buf == '':
                out_buf += "\"'\",'"
                i += 1
            else:
                out_buf += "',\"'\",'"
                i += 1
        else:
            if out_buf == '':
                out_buf += "'" + cc[i]
                i += 1
            else:
                out_buf += cc[i]
                i += 1
    if out_buf != '':
        out_buf += "'"
        if out_buf[-3:] == ",''":
            out_buf = out_buf[:-3]
        if xx[i] == 0:
            out_buf += ",0"
            i += 1
        print("{}db {}".format(tabs, out_buf))
        out_buf = ''
    if xx[i] == xx[i + 1]:
        x = xx[i]
        i += 2
        c = 2
        while xx[i] == x:
            c += 1
            i += 1
        if c > 2:
            print('{}db {} dup ({})'.format(tabs, c, x))
            continue
        else:
            i -= 2
    if ss[i:][:4] == 'PQRS' and in_bare:
        print(tabs + 'push ax')
        print(tabs + 'push cx')
        print(tabs + 'push dx')
        print(tabs + 'push bx')
        i += 4
    else:
        comment = ''
        if xx[i] > 127:
            nobit7 = xx[i] - 128
            if nobit7 >= 32 and nobit7 < 127:
                comment = '\t; \'{}\' + 80h'.format(chr(nobit7))
        print("{}db {}{}".format(tabs, xx[i], comment));
        i += 1


if asm:
    print("\
\n\
_TEXT           ends\n\
\n\
                end     _main\
");
