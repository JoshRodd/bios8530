; Prints all 256 characters of given font.

_TEXT           segment para public 'CODE'
                org 100h
                assume cs:_TEXT,ds:_TEXT,ss:_TEXT

; =============== S U B R O U T I N E =======================================

; Choose the current display page for all video operations

_start          proc near
                mov     bh, 0

print_blank_line:                       ; CODE XREF: _start+37↓j
                mov     ds:chars_left_on_this_line, 64 ; Store 64 character locations left before next newline
                nop
                mov     ah, 0Eh         ; Print blank line (CR+LF)
                mov     al, 0Dh
                int     10h             ; - VIDEO - WRITE CHARACTER AND ADVANCE CURSOR (TTY WRITE)
                                        ; AL = character, BH = display page (alpha modes)
                                        ; BL = foreground color (graphics modes)
                mov     ah, 0Eh
                mov     al, 0Ah
                int     10h             ; - VIDEO - WRITE CHARACTER AND ADVANCE CURSOR (TTY WRITE)
                                        ; AL = character, BH = display page (alpha modes)
                                        ; BL = foreground color (graphics modes)
                dec     ds:lines_left   ; 5 lines total, one blank line + 4 * 64 = 256 chars total
                jz      short exit_program ; Exit to DOS

print_char:                             ; CODE XREF: _start+35↓j
                mov     ah, 0Ah
                mov     al, ds:char_counter
                mov     cx, 1
                int     10h             ; - VIDEO - WRITE CHARACTERS ONLY AT CURSOR POSITION
                                        ; AL = character, BH = display page - alpha mode
                                        ; BL = color of character (graphics mode, PCjr only)
                                        ; CX = number of times to write character
                inc     ds:char_counter
                mov     ah, 3
                int     10h             ; - VIDEO - READ CURSOR POSITION
                                        ; BH = page number
                                        ; Return: DH,DL = row,column, CH = cursor start line, CL = cursor end line
                inc     dx
                mov     ah, 2
                int     10h             ; - VIDEO - SET CURSOR POSITION
                                        ; DH,DL = row, column (0,0 = upper left)
                                        ; BH = page number
                dec     ds:chars_left_on_this_line
                jnz     short print_char
                jmp     short print_blank_line ; Store 64 character locations left before next newline
; ---------------------------------------------------------------------------

exit_program:                           ; CODE XREF: _start+18↑j
                retn                    ; Exit to DOS
_start          endp

; ---------------------------------------------------------------------------
char_counter    db 0                    ; DATA XREF: _start+1C↑r
                                        ; _start+24↑w
chars_left_on_this_line db 0            ; DATA XREF: _start:print_blank_line↑w
                                        ; _start+31↑w
lines_left      db 5                    ; DATA XREF: _start+14↑w
_TEXT           ends


                end     _start
