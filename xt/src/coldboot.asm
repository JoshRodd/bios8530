; coldboot.asm

                name    coldboot

DGROUP          group   _TEXT,CONST,_DATA,_BSS,STACK

_TEXT           segment para public 'CODE'
                assume  cs:_TEXT,ds:nothing,es:nothing,ss:nothing

                org     100h

_start          proc    far

                ; Check for being loaded org 0 instead of 100h
l001:
                call    l002
                dw      0,0
l002:           pop     bx
                cmp     bx,(offset l002)-100h ; Is it 100h off?
                jnz     l003
                cmp     bx,offset l002 ; Is it correct?
                jz      l004    ; If not, don't
l005:           hlt             ; continue
                jmp     l005
l004:           sub     bx,4
                mov     word ptr cs:[bx],offset l001
                mov     ax,cs
                sub     ax,10h  ; Move 10h paragraphs back (100h bytes)
                mov     cs:[bx+2],ax
                jmp     dword ptr cs:[bx]
l003:
                ; Set up our own stack
                mov     dx,cs
                mov     bx,offset _stack_top
                cli
                mov     ss,dx
                assume  ss:DGROUP
                mov     sp,bx
                mov     ax,0f202h ; V0 D0 I1 T0 S0 Z0 A0 P0 C0
                push    ax
                popf
                mov     es,dx
                assume  es:DGROUP

                ; Wipe out from stack end through next 64kB boundary
                mov     di,offset _stack_end
                ; If stack top isn't paragraph aligned, wipe out the
                ; rest of the paragraph first
                mov     al,'@'
align_para:     test    di,0fh
                jnz     stack_aligned
                stosb
                ; Check for crossing a 64kB boundary
                or      di,di
                jnz     align_para
                add     dx,1000h
                mov     es,dx
                jmp     align_para
                ; ES:DI is now paragraph aligned, so normalise ES:DI
                ; to ES:0.
stack_aligned:  mov     cx,es
                shr     di,1
                shr     di,1
                shr     di,1
                shr     di,1
                add     cx,di
                mov     es,cx
                xor     di,di
                ; Now compute how many paragraphs until the next
                ; 64kB bank.
                and     cx,0fffh
                ; Turn number of paragraphs into words (* 8).
                shl     cx,1
                shl     cx,1
                shl     cx,1
                ; Blank out the rest of the bank.
                mov     ax,2524h   ; '$#'
                rep     stosw
                ; Normalise ES:DI again. It will be on a bank
                ; boundary.
                mov     ax,es
                and     ax,0f000h
next_bank:      add     ax,1000h
                mov     es,bx
                xor     di,di
                cmp     ax,0c000h
                jae     banks_done
                mov     cx,8000h    ; Store 32k words
                mov     ax,2726h    ; '%^'
                rep     stosw
                mov     ax,es
                jmp     next_bank
                
banks_done:     ; If we have our signature at 472h, just
                ; execute int 67h to return to the monitor.
                ; This catches if attemptes to cold boot
                ; result in immediately running this program
                ; again.
                xor     ax,ax
                mov     ds,ax
                mov     bx,472h
                mov     dx,0beefh
                cmp     ds:[bx],dx
                jne     do_coldboot
                ; Get rid of our signature
                mov     ds:[bx],ax
                xor     ax,ax
                int     67h
                int     20h
                ret
do_coldboot:    ; Otherwise, try to cold boot
                mov     ds:[bx],dx      ; Clear out a 1234h signature
                ret
        
_start          endp

_TEXT           ends

CONST           segment para public 'CONST'
CONST           ends

_DATA           segment para public 'DATA'
_DATA           ends

_BSS            segment para public 'BSS'
_BSS            ends

; Stack is 256 bytes
STACK           segment para stack 'STACK'

                db      30 dup ('STACK!!!')
;                dw      0,-1,0f202h ; equivalent to JMP FAR 0FFFFh:0
_stack_top      equ     $
                db      'STACK!!!'
_stack_end      equ     $
                db      'STACKEND'

; Pattern afer this will be '@@@@#$#$#$#$%^%^%^'

STACK           ends

                end     _start
