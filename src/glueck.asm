; This is a source version GLUECK.SYS. It builds
; the same version as Version 1.01, 8 June 1989
; if the welcome banner is set to the same as
; that version.
;
; GLUECK.SYS takes no parameters. It will load an
; 8x16 font that is embedded starting at org 18h,
; uncompressed, 4,096 bytes with 16 bytes per
; character for a total of 256 characters. The
; binary file can be edited in place to store a
; different font; the WESLEY.COM utility does 
; exactly that if the /p option is used. The size
; of the font is specified at org 16h, which is
; normally set to 4,096.
;
; GLUECK.SYS alters the video BIOS font tables
; to instead use the font it contains in memory.
; This will apply to any mode that uses an 8x16
; or 9x16 font, including modes 0-3, 7, 11h, and
; 12h, whether alphanumeric or graphics modes.
;
; GLUECK.SYS is compatible with IBM VGA and MCGA
; display BIOS. It has been tested on a PS/2 Model
; 25 (8086 model with MCGA), on various VGA
; hardware, and on pcjs.org emulating a PC/XT with
; a VGA.
;
; GLUECK.SYS does not hook any interrupts such as
; INT 10h. It is delivered as a device driver with
; an objective to consume less RAM than a TSR would.
;
; GLUECK.SYS can load a different font after it is
; loaded by sending a character device generic
; IOCtl request; the font data should be delivered
; as 4,096 bytes or less. Delivering more data than
; this will overwrite code and possibly result in a
; crash. The driver can be accessed via the
; character deivce name of "HOWARD!".
;
; Character sizes other than 8x16 are supported by
; setting the font size appropriately. Any character
; height is supported from 4 to 16. GLUECK.SYS will
; compute the cell height by dividing the size of
; the font by 256, and it then informs the BIOS of
; the new size.
;
; GLUECK.SYS requires DOS version 3.30 or above,
; although there is no strict grounds for this
; requirement; DOS version 3.20 is required for
; Generic IOCtl, DOS version 2.00 is required for
; loadable device drivers. IBM did not release
; any machine with VGA or MCGA with a DOS version
; prior to 3.30.

dos_device_request_hdr  struc
request_hdr_len         db ?
request_hdr_subunit     db ?
request_hdr_cmd_code    db ?
request_hdr_status      dw ? 
request_hdr_reserved    db 9 dup(?)
request_hdr_address     dd ?
request_hdr_count       dw ?
dos_device_request_hdr  ends

_TEXT           segment para public 'CODE'
                org 0
                assume cs:_TEXT
                assume es:nothing, ss:nothing, ds:nothing
devdrvr_hdr_next_drvr dd -1             ; always set to 0FFFFh (pointer to next device driver)
devdrvr_hdr_drvrflags dw 1100000000000000b ; bit 15 1=character device, bit 14 1=IOCtl supported
devdrvr_hdr_strategy dw offset strategy_routine
devdrvr_hdr_interrupt dw offset interrupt_routine
devdrvr_hdr_devname db 'HOWARD! '       ; Name of device
request_header  dd 0                    ; Stores request block from interrupt routine
raw_font_size   dw 1000h                ; Size of current font. This is
    ; normally a multiple of 256.
raw_font_data   label   near

include howard16.inc                    ; This is the default font

; =============== S U B R O U T I N E =======================================


strategy_routine proc far               ; DATA XREF: _TEXT:devdrvr_hdr_strategy↑o
                mov     word ptr cs:request_header, bx ; Stores device request header from strategy routine
                mov     word ptr cs:request_header+2, es ; Stores device request header from strategy routine
                retf
strategy_routine endp


; =============== S U B R O U T I N E =======================================

DEV_CMD_INIT    equ     0
DEV_CMD_IOCTL   equ     0Ch

interrupt_routine proc far              ; DATA XREF: _TEXT:devdrvr_hdr_interrupt↑o
                push    ax
                push    bx
                push    es
                les     bx, cs:request_header ; Stores device request header from strategy routine
                cmp     es:[bx+dos_device_request_hdr.request_hdr_cmd_code], DEV_CMD_INIT
                jz      short device_command_init
                cmp     es:[bx+dos_device_request_hdr.request_hdr_cmd_code], DEV_CMD_IOCTL
                jz      short device_command_ioctl_output
                mov     es:[bx+dos_device_request_hdr.request_hdr_status], 1000000100000011b ; error + done + 03h "unknown command"
                jmp     short device_command_return
; ---------------------------------------------------------------------------

device_command_init:                    ; CODE XREF: interrupt_routine+D↑j
                call    do_init         ; Tell DOS to throw away all data/code from banner onward
                jmp     short device_command_return
; ---------------------------------------------------------------------------

device_command_ioctl_output:            ; CODE XREF: interrupt_routine+14↑j
                call    do_ioctl_output

device_command_return:                  ; CODE XREF: interrupt_routine+1C↑j
                                        ; interrupt_routine+21↑j
                les     bx, cs:request_header ; Stores device request header from strategy routine
                mov     es:[bx+dos_device_request_hdr.request_hdr_status], 100h ; done
                pop     es
                pop     bx
                pop     ax
                retf
interrupt_routine endp


; =============== S U B R O U T I N E =======================================


do_ioctl_output proc near               ; CODE XREF: interrupt_routine:device_command_ioctl_output↑p
                cld
                push    cx
                push    si
                push    di
                push    ds
                mov     cx, es:[bx+dos_device_request_hdr.request_hdr_count] ; Store the number of bytes in the font
                mov     cs:raw_font_size, cx
                lds     si, es:[bx+dos_device_request_hdr.request_hdr_address]
                push    cs
                pop     es
                mov     di, offset raw_font_data
                shr     cx, 1           ; CX = raw_font_size / 2
                rep movsw               ; Copy raw font data from IOCtl output
                mov     cl, byte ptr cs:raw_font_size+1 ; raw_font_size / 256 (height of this font, normally 16)
                mov     cs:font_scanline_height, cl ; Store that
                mov     cs:fontsize_and_scanline_height, cx ; Store 2064 for a 16 scanline high font
                mov     ax, 400
                div     cl              ; Store 25 for a 16 high font (400 / raw_font_size / 256)
                mov     cs:num_rows_400scanlines, al ; number of character rows displayed (defaults to 25)
                mov     ax, 480
                div     cl              ; Store 30 for a 16 high font (480 / raw_font_size / 256)
                mov     cs:num_rows_480scanlines, al ; number of character rows display in graphics mode (defaults to 30)
                pop     ds
                pop     di
                pop     si
                pop     cx
                retn
do_ioctl_output endp

; ---------------------------------------------------------------------------
override_00     dw 0                    ; DATA XREF: hook_video_parms+1D↓w
                                        ; hook_video_parms+49↓o
                                        ; Video Parameter Table pointer offset
override_02     dw 0                    ; DATA XREF: hook_video_parms+25↓w
                                        ; Video Parameter Table pointer segment
override_04     dw 0                    ; DATA XREF: hook_video_parms+2D↓w
                                        ; Dynamic Parameter Save Area pointer offset
override_06     dw 0                    ; DATA XREF: hook_video_parms+35↓w
                                        ; Dynamic Parameter Save Area pointer segment
override_08     dw offset font_scanline_height ; Alphanumeric Character Set Override pointer offset
override_0A     dw 0                    ; DATA XREF: hook_video_parms+1↓w
                                        ; Alphanumeric Character Set Override pointer segment (set to CS)
override_0C     dw offset num_rows_480scanlines ; Graphics Character Set Override pointer offset
override_0E     dw 0                    ; DATA XREF: hook_video_parms+5↓w
                                        ; Graphics Character Set Override pointer segment (set to CS)
override_10     dw 0                    ; DATA XREF: hook_video_parms+3D↓w
                                        ; Secondary Save Pointer Table pointer offset
override_12     dw 0                    ; DATA XREF: hook_video_parms+45↓w
                                        ; Secondary Save Pointer Table pointer segment
override_14     dd 0                    ; Reserved
override_18     dd 0                    ; Reserved
font_scanline_height db 0               ; DATA XREF: do_ioctl_output+20↑w
                                        ; _TEXT:override_08↑o ...
                                        ; length of each character definition in bytes (defaults to 16)
                db 0                    ; character generator RAM bank
                dw 256                  ; count of characters defined (256)
                dw 0                    ; first character code in table
font_table_pointer_1_offset dw offset raw_font_data ; pointer to character font definition table offset
font_table_pointer_1_segment dw 0       ; DATA XREF: hook_video_parms+9↓w
                                        ; pointer to character font definition table segment (set to CS)
num_rows_400scanlines db 0              ; DATA XREF: do_ioctl_output+2F↑w
                                        ; do_init+30↓w
                                        ; number of character rows displayed (defaults to 25)
applicable_video_modes_array db 0,1,2,3,7,0FFh ; array of applicable video modes; ends in 0FFh
num_rows_480scanlines db 0              ; DATA XREF: do_ioctl_output+38↑w
                                        ; _TEXT:override_0C↑o ...
                                        ; number of character rows display in graphics mode (defaults to 30)
fontsize_and_scanline_height dw 0       ; DATA XREF: do_ioctl_output+25↑w
                                        ; do_init+26↓w
                                        ; length of each character definition in bytes (defaults to 16)
font_table_pointer_2_offset dw offset raw_font_data ; pointer to character font definition table offset
font_table_pointer_2_segment dw 0       ; DATA XREF: hook_video_parms+D↓w
                                        ; pointer to character font definition table segment (set to CS)
applicable_graphics_modes_array db 11h,12h,0FFh ; array of applicable video modes for graphics mode; ends in 0FFh
banner          db 0Dh,0Ah,0C9h,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh
                                        ; DATA XREF: do_init↓o
                                        ; do_init+45↓o
                db 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh
                db 0CDh, 0CDh, 0CDh, 0CDh, 0BBh, 0Dh, 0Ah
                db 0BAh,' >>>>>  HOWARD the FONT  <<<<< ',0BAh,0Dh,0Ah
                db 0BAh,' *** IBM Internal Use Only *** ',0BAh,0Dh,0Ah
                db 0BAh,' Version 1.01  ',0C4h,0C4h,'  08 Jun 1989 ',0BAh,0Dh,0Ah
                db 0BAh,'  Programmer: Alan E. Beelitz  ',0BAh,0Dh,0Ah
                db 0BAh,' Inspiration: Howard W. Glueck ',0BAh,0Dh,0Ah
                db 0C8h,0CDh,0CDh,0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0BCh, 0Dh, 0Ah
                db 0Ah
                db 0
no_vga_mcga_message db 0Dh,0Ah          ; DATA XREF: check_min_reqs↓o
                db 'GLUECK requires a VGA or MCGA display adapter.',0Dh,0Ah,0
no_dos_3_3_message db 0Dh,0Ah           ; DATA XREF: check_min_reqs+C↓o
                db 'GLUECK requires DOS Version 3.30 or above.',0Dh,0Ah,0

; =============== S U B R O U T I N E =======================================

; Tell DOS to throw away all data/code from banner onward

do_init         proc near               ; CODE XREF: interrupt_routine:device_command_init↑p
                mov     word ptr es:[bx+0Eh], offset banner ; "\r\n���������������������������������\r"...
                mov     word ptr es:[bx+10h], cs
                push    cx
                push    si
                push    ds
                mov     ax, cs
                mov     ds, ax
                cld
                call    check_min_reqs
                jb      short do_init_return
                call    hook_video_parms
                mov     cl, byte ptr cs:raw_font_size+1
                mov     cs:font_scanline_height, cl ; length of each character definition in bytes (defaults to 16)
                xor     ch, ch
                mov     cs:fontsize_and_scanline_height, cx ; length of each character definition in bytes (defaults to 16)
                mov     ax, 400
                div     cl
                mov     cs:num_rows_400scanlines, al ; number of character rows displayed (defaults to 25)
                mov     ax, 480
                div     cl
                mov     cs:num_rows_480scanlines, al ; number of character rows display in graphics mode (defaults to 30)
                mov     ah, 0Fh
                int     10h             ; - VIDEO - GET CURRENT VIDEO MODE
                                        ; Return: AH = number of columns on screen
                                        ; AL = current video mode
                                        ; BH = current active display page
                mov     ah, 0
                int     10h             ; - VIDEO - SET VIDEO MODE
                                        ; AL = mode
                mov     si, offset banner ; "\r\n���������������������������������\r"...
                call    print_message

do_init_return:                         ; CODE XREF: do_init+15↑j
                pop     ds
                pop     si
                pop     cx
                retn
do_init         endp


; =============== S U B R O U T I N E =======================================


check_min_reqs  proc near               ; CODE XREF: do_init+12↑p
                mov     si, offset no_vga_mcga_message ; "\r\nGLUECK requires a VGA or MCGA displ"...
                mov     ax, 1A00h
                int     10h             ; - VIDEO - DISPLAY COMBINATION (PS,VGA/MCGA): read display combination code
                cmp     al, 1Ah
                jnz     short print_error_message
                mov     si, offset no_dos_3_3_message ; "\r\nGLUECK requires DOS Version 3.30 or"...
                mov     ah, 30h
                int     21h             ; DOS - GET DOS VERSION
                                        ; Return: AL = major version number (00h for DOS 1.x)
                cmp     al, 3           ; Major version 3 or greater?
                ja      short successful_min_reqs_check ; Version is 4.0 higher, so success
                jb      short print_error_message ; Version is 2.x or lower, so failure
                cmp     ah, 30          ; Version 3.x, so check for minor version 3.30 or higher
                jnb     short successful_min_reqs_check ; Minor version is .30 or higher, so success

print_error_message:                    ; CODE XREF: check_min_reqs+A↑j
                                        ; check_min_reqs+17↑j
                call    print_message
                les     bx, cs:request_header ; Stores device request header from strategy routine
                mov     word ptr es:[bx+0Eh], 0
                stc

successful_min_reqs_check:              ; CODE XREF: check_min_reqs+15↑j
                                        ; check_min_reqs+1C↑j
                retn
check_min_reqs  endp


; =============== S U B R O U T I N E =======================================


hook_video_parms proc near              ; CODE XREF: do_init+17↑p
                push    ds
                mov     ds:override_0A, cs ; Alphanumeric Character Set Override pointer segment (set to CS)
                mov     ds:override_0E, cs ; Graphics Character Set Override pointer segment (set to CS)
                mov     ds:font_table_pointer_1_segment, cs ; pointer to character font definition table segment (set to CS)
                mov     ds:font_table_pointer_2_segment, cs ; pointer to character font definition table segment (set to CS)
                mov     ax, 40h
                mov     ds, ax
                assume ds:nothing
                les     bx, ds:0A8h     ; BIOS video save/override pointer table address
                mov     ax, es:[bx]     ; Video Parameter Table pointer low word
                mov     cs:override_00, ax ; Video Parameter Table pointer offset
                mov     ax, es:[bx+2]   ; Video Parameter Table pointer high word
                mov     cs:override_02, ax ; Video Parameter Table pointer segment
                mov     ax, es:[bx+4]   ; Dynamic Parameter Save Area pointer low word
                mov     cs:override_04, ax ; Dynamic Parameter Save Area pointer offset
                mov     ax, es:[bx+6]   ; Dynamic Parameter Table Save Area pointer high word
                mov     cs:override_06, ax ; Dynamic Parameter Save Area pointer segment
                mov     ax, es:[bx+10h] ; Alphanumeric Character Set Override pointer low word
                mov     cs:override_10, ax ; Secondary Save Pointer Table pointer offset
                mov     ax, es:[bx+12h] ; Alphanumeric Character Set Override pointer high word
                mov     cs:override_12, ax ; Secondary Save Pointer Table pointer segment
                mov     word ptr ds:0A8h, offset override_00 ; BIOS video save/override pointer table address
                mov     word ptr ds:0AAh, cs
                pop     ds
                assume ds:nothing
                retn
hook_video_parms endp


BIOS_VIDEO_WRITE_TTY    equ 0Eh

; print_message:
;
; Print a null-terminated string in DS:SI, using the
; colour attribute in BL and the page in BH.

print_message   proc near

print_msg_loop: lodsb
                mov     ah, BIOS_VIDEO_WRITE_TTY
                int     10h        
                cmp     byte ptr [si], 0
                jnz     print_msg_loop
                retn
print_message   endp

_TEXT           ends

                end
