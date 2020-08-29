; Clears the screen quickly.

DEFAULT_ROWS    equ 25

BIOS_SET_CURSOR equ 2
VIDEO_MODE_MONO equ 7
BIOS_VIDEO      equ 10h
DOS_PRINT       equ 9
DOS_EXIT        equ 4ch
DOS_CALL        equ 21h

_TEXT           segment para public 'CODE'
                assume cs:_TEXT,ds:_TEXT,es:nothing,ss:_TEXT
                org 100h

; =============== S U B R O U T I N E =======================================

; Attributes: noreturn

_start          proc near
                mov     ds, bios_data_seg_var
                assume  ds:_BIOS_DATA_SEG
                cmp     current_video_mode, VIDEO_MODE_MONO ; Is the current video mode MONO (7)?
                ja      short print_error_message ; Graphics modes above 7 aren't supported, so print error and quit
                jb      short skip_is_mono_mode ; This is a colour mode (0-6)
                mov     cs:display_buffer_seg, seg _MONO_DISPLAY_SEG ; Yes, this 7, so load mono display buffer segment

skip_is_mono_mode:                      ; CODE XREF: _start+B↑j
                call    clear_screen 
                mov     ah, BIOS_SET_CURSOR           ; Move the cursor to the top left.
                mov     bh, current_display_page      ; Set the cursor to the current display page.
                xor     dx, dx
                int     BIOS_VIDEO             ; - VIDEO - SET CURSOR POSITION
                                        ; DH,DL = row, column (0,0 = upper left)
                                        ; BH = page number
                jmp     short exit_program
; ---------------------------------------------------------------------------

print_error_message:                    ; CODE XREF: _start+9↑j
                push    cs
                pop     ds              ; Restore DS
                assume ds:_TEXT
                mov     ah, DOS_PRINT
                mov     dx, offset error_message ; "\r\nClrScr cannot be run in this displa"...
                int     DOS_CALL             ; DOS - PRINT STRING
                                        ; DS:DX -> string terminated by "$"

exit_program:                           ; CODE XREF: _start+21↑j
                mov     ax, DOS_EXIT * 256
                int     DOS_CALL             ; DOS - 2+ - QUIT WITH EXIT CODE (EXIT)
_start          endp                    ; AL = exit code


; =============== S U B R O U T I N E =======================================


clear_screen    proc near               ; CODE XREF: _start:skip_is_mono_mode↑p
                assume  ds:_BIOS_DATA_SEG
                mov     ax, cs:display_buffer_seg ; Defaults to colour display buffer segment
                add     ax, ds:current_page_offset      ; Set our destination to the current video page's offset.
                mov     es, ax
                assume  es:_COLOR_DISPLAY_SEG
                mov     ax, num_columns      ; Find out the number of columns on the screen.
                mov     cl, num_rows      ; Find out the number of rows on the screen (EGA+ only), or else 0.
                or      cl, cl
                jnz     short skip_is_zero_rows ; If claimed number of rows is (CGA or Mono BIOS), then default to 25.
                mov     cl, DEFAULT_ROWS - 1

skip_is_zero_rows:                      ; CODE XREF: sub_131+13↑j
                inc     cl              ; Number of rows is 0 based not 1 based
                mul     cl              ; Rows x Columns
                mov     cx, ax
                mov     ah, row2column1attr      ; Get the attribute of the first column, second row (or fourth row in 40 col. modes)
                mov     al, ' '         ; Blank the screen to the space character
                xor     di, di
                rep stosw               ; Blank the screen.
                retn
clear_screen    endp

; ---------------------------------------------------------------------------
bios_data_seg_var   dw seg _BIOS_DATA_SEG              ; DATA XREF: _start↑r
display_buffer_seg dw seg _COLOR_DISPLAY_SEG            ; DATA XREF: _start+D↑w
                                        ; sub_131↑r
                                        ; Defaults to colour display buffer segment
error_message   db 0Dh,0Ah              ; DATA XREF: _start+27↑o
                db 'ClrScr cannot be run in this display mode.',0Dh,0Ah,'$'
_TEXT           ends

_BIOS_DATA_SEG  segment para at 40h
                org     49h
current_video_mode      db  ?
                org     4ah
num_columns             dw  ?
                org     4eh
current_page_offset     dw  ?
                org     62h
current_display_page    db  ?
                org     84h
num_rows                db  ?
_BIOS_DATA_SEG  ends

_COLOR_DISPLAY_SEG  segment para at 0b800h

                ;      row 2         column 1          attribute
                org     (((2 - 1) * (80) + (1 - 1)) * 2) + 1
row2column1attr         db  ?

_COLOR_DISPLAY_SEG  ends

_MONO_DISPLAY_SEG   segment para at 0b000h
_MONO_DISPLAY_SEG   ends
                
                end     _start
