; Like MODE MONO, but faster.

_TEXT   segment para public 'CODE'
        org     0100h
        assume  cs:_TEXT,ds:_TEXT,ss:_TEXT

_start  proc    near

        mov     ax,7
        int     10h
        mov     ax,4c00h
        int     21h

_start  endp

_TEXT   ends

        end     _start
