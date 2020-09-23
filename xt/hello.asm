; hello.asm

                name    hello

DGROUP          group   _TEXT,CONST,_DATA,_BSS

_TEXT           segment para public 'CODE'
                assume  cs:_TEXT,ds:nothing,es:nothing,ss:nothing

                org     0

_start          proc    far

;               call    _main
;               xor     ax,ax
;               int     67h
;               int     20h
;               ret

_start          endp

;               org     100h

_main           proc    near

                mov     ax,cs
                mov     ds,ax
                assume  ds:DGROUP
                mov     ax,3
                int     10h
                mov     si,offset message
                mov     cx,offset messageEnd-offset message
                call    printMessage
                mov     ax,cs
                int     63h
                mov     si,offset message2
                mov     cx,offset message2End-offset message2
                call    printMessage

                mov     ax,0b000h
                mov     es,ax
                mov     cx,-1
                xor     di,di
l4:             mov     ax,di
                stosb
                loop    l4

                mov     dl,1    ; DL:CX = first 64kB
                mov     cx,0
                xor     ax,ax
                mov     ds,ax
                xor     si,si
                int     66h

                mov     cx,-1
                loop    $

                int     60h
        
;               ret
                int     67h

_main           endp

printMessage    proc near

                push    si
                push    cx
                int     64h
                pop     cx
                pop     si
                mov     ax,0b000h
                mov     es,ax
                xor     di,di
                mov     ah,7
                jcxz    l2
l1:             lodsb
                mov     es:[di+8000h],ax
                stosw
                cmp     byte ptr [si],0
                jz      l2
                loop    l1
l2:             ret

printMessage    endp

_TEXT           ends

CONST           segment para public 'CONST'

message         db      "CODE SEGMENT IS: "
messageEnd      db      0

message2        db      "h",10
message2End     db      0

                db      600h/4 dup (0DEh,0ADh,0BEh,0EFh)
                db      0C0h,0FFh,0EEh

CONST           ends

_DATA           segment para public 'DATA'
_DATA           ends

_BSS            segment para public 'BSS'
_BSS            ends

                end     _start
