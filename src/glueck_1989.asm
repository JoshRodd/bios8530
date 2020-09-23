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


; Header with useful constants and so forth
include glueck.inc


; Our device name.
DEVICE_NAME     equ GLUECK_DEVICE_NAME


; Assemble all segments into one segment similar to a tiny memory model.
CGROUP          group   _DEV_HDR,_DATA_1,_TEXT,_DATA,INIT_DATA,INIT_TEXT


; Standard DOS device driver header

_DEV_HDR        segment para public 'DRIVER'
                org 0

; always set to 0FFFFh (pointer to next device driver)
devdrvr_hdr_next_drvr:
                dd -1

; bit 15 1=character device, bit 14 1=IOCtl supported
devdrvr_hdr_drvrflags:
                dw 1100000000000000b

; Pointers to strategy and interrupt routines.
devdrvr_hdr_strategy:
                dw offset strtgy_routine

devdrvr_hdr_interrupt:
                dw offset intrpt_routine

; Name of character device.
devdrvr_hdr_devname:
                db DEVICE_NAME

_DEV_HDR        ends


; Resident data

_DATA_1         segment byte public 'DRIVER'

; Stores request block from interrupt routine
request_header  dd 0
raw_font_size   dw 1000h                ; Size of current font. This is
    ; normally a multiple of 256.
raw_font_data   label   near

include howard16.inc                    ; This is the default font

_DATA_1 ends


; Resident code

_TEXT           segment byte public 'DRIVER'
                assume cs:CGROUP, es:nothing, ss:nothing, ds:nothing

strtgy_routine  proc    far
                ; Store pointer to device request block
                mov     word ptr cs:request_header, bx
                mov     word ptr cs:request_header+2, es
                retf
strtgy_routine  endp

intrpt_routine  proc    far
                push    ax
                push    bx
                push    es

                les     bx, cs:request_header ; Stores device request header from strategy routine

                cmp     es:[bx+dos_device_request_hdr.request_hdr_cmd_code], DEV_CMD_INIT
                jz      short device_command_init

                cmp     es:[bx+dos_device_request_hdr.request_hdr_cmd_code], DEV_CMD_IOCTL
                jz      short device_command_ioctl_output

                ; Error for unknown commands.
                mov     es:[bx+dos_device_request_hdr.request_hdr_status], 1000000100000011b ; error + done + 03h "unknown command"
                jmp     short device_command_return

device_command_init:
                call    do_init
                jmp     short device_command_return

device_command_ioctl_output:
                call    do_ioctl_output

; Returns with a successful return code (100h = "DONE").
device_command_return:
                les     bx, cs:request_header
                mov     es:[bx+dos_device_request_hdr.request_hdr_status], 100h ; done

                pop     es
                pop     bx
                pop     ax
                retf
intrpt_routine  endp

; Generic IOCtl request; loads a new font.
do_ioctl_output proc    near
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
                rep     movsw           ; Copy raw font data from IOCtl output
                mov     cl, byte ptr cs:raw_font_size+1 ; raw_font_size / 256 (height of this font, normally 16)
                mov     cs:font_scanline_height, cl ; Store that
                mov     cs:fontsize_and_scanline_height, cx ; Store 2064 for a 16 scanline high font
                mov     ax, VGA_ALPHANUM_400LINES
                div     cl              ; Store 25 for a 16 high font (400 / raw_font_size / 256)
                mov     cs:num_rows_400scanlines, al ; number of character rows displayed (defaults to 25)
                mov     ax, VGA_GRAPHICS_480LINES
                div     cl              ; Store 30 for a 16 high font (480 / raw_font_size / 256)
                mov     cs:num_rows_480scanlines, al ; number of character rows display in graphics mode (defaults to 30)
                pop     ds
                pop     di
                pop     si
                pop     cx
                retn
do_ioctl_output endp

_TEXT           ends


; Main resident data area

_DATA           segment byte public 'DRIVER'

; ---------------------------------------------------------------------------
override_00     dw 0 ; Video Parameter Table pointer offset
override_02     dw 0 ; Video Parameter Table pointer segment
override_04     dw 0 ; Dynamic Parameter Save Area pointer offset
override_06     dw 0 ; Dynamic Parameter Save Area pointer segment
override_08     dw offset font_scanline_height ; Alphanumeric Character Set Override pointer offset
override_0A     dw 0 ; Alphanumeric Character Set Override pointer segment (set to CS)
override_0C     dw offset num_rows_480scanlines ; Graphics Character Set Override pointer offset
override_0E     dw 0 ; Graphics Character Set Override pointer segment (set to CS)
override_10     dw 0 ; Secondary Save Pointer Table pointer offset
override_12     dw 0 ; Secondary Save Pointer Table pointer segment
override_14     dd 0                    ; Reserved
override_18     dd 0                    ; Reserved
font_scanline_height db 0 ; length of each character definition in bytes (defaults to 16)
                db 0                    ; character generator RAM bank
                dw NUM_CHARACTERS       ; count of characters defined (256)
                dw 0                    ; first character code in table
font_table_pointer_1_offset dw offset raw_font_data ; pointer to character font definition table offset
font_table_pointer_1_segment dw 0 ; pointer to character font definition table segment (set to CS)
num_rows_400scanlines db 0        ; number of character rows displayed (defaults to 25)
applicable_video_modes_array db 0,1,2,3,7,0FFh ; array of applicable video modes; ends in 0FFh
num_rows_480scanlines db 0        ; number of character rows display in graphics mode (defaults to 30)
fontsize_and_scanline_height dw 0 ; length of each character definition in bytes (defaults to 16)
font_table_pointer_2_offset dw offset raw_font_data ; pointer to character font definition table offset
font_table_pointer_2_segment dw 0 ; pointer to character font definition table segment (set to CS)
applicable_graphics_modes_array db 11h,12h,0FFh ; array of applicable video modes for graphics mode; ends in 0FFh

resident_trunc  label   near

_DATA           ends


; Initialisation only data. This gets discarded after INIT is called.

INIT_DATA       segment byte public 'DRIVER'

banner          db 13,10
                db 0C9h,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh
                db 0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh
                db 0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0BBh,13,10
                db 0BAh,' >>>>>  HOWARD the FONT  <<<<< ',0BAh,13,10
                db 0BAh,' *** IBM Internal Use Only *** ',0BAh,13,10
                db 0BAh,' Version 1.01  ',0C4h,0C4h
                db                       '  08 Jun 1989 ',0BAh,13,10
                db 0BAh,'  Programmer: Alan E. Beelitz  ',0BAh,13,10
                db 0BAh,' Inspiration: Howard W. Glueck ',0BAh,13,10
                db 0C8h,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh
                db 0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh
                db 0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0CDh,0BCh,13,10
                db 10
                db 0

no_vga_mcga_message db 13,10
                db 'GLUECK requires a VGA or MCGA display adapter.',13,10,0

no_dos_3_3_message db 13,10
                db 'GLUECK requires DOS Version 3.30 or above.',13,10,0

INIT_DATA       ends


; Initalisation only code. This gets discarded after INIT is called.

INIT_TEXT       segment byte public 'DRIVER'

; do_init:
;
; Load the initial font, clear the screen, print banner, and
; then return to DOS.

do_init         proc near

                ; Tell DOS to throw away all data/code from banner onward
                mov     word ptr es:[bx+dos_device_request_hdr.request_hdr_address], offset resident_trunc
                mov     word ptr es:[bx+dos_device_request_hdr.request_hdr_address+2], cs

                ;
                push    cx
                push    si
                push    ds
                mov     ax, cs
                mov     ds, ax
                assume  ds:CGROUP

                ; Set direction flag for lodsb in print_message
                cld

                ; Check for DOS 3.30 and VGA or MCGA
                call    check_min_reqs
                ; If failed, immediately exit
                jb      short do_init_return

                ; Install our video mode override
                call    hook_video_parms

                ; Install our font. Same code as the generic IOCtl handler.
                mov     cl, byte ptr cs:raw_font_size+1
                mov     cs:font_scanline_height, cl ; length of each character definition in bytes (defaults to 16)
                xor     ch, ch
                mov     cs:fontsize_and_scanline_height, cx ; length of each character definition in bytes (defaults to 16)
                mov     ax, VGA_ALPHANUM_400LINES
                div     cl
                mov     cs:num_rows_400scanlines, al ; number of character rows displayed (defaults to 25)
                mov     ax, VGA_GRAPHICS_480LINES
                div     cl
                mov     cs:num_rows_480scanlines, al ; number of character rows display in graphics mode (defaults to 30)
                mov     ah, BIOS_VIDEO_GET_MODE
                int     BIOS_VIDEO
                ; BH is now the current video page
                mov     ah, BIOS_VIDEO_SET_MODE ; Set the same mode to load the font
                int     BIOS_VIDEO
                ; Print the banner.
                mov     si, offset banner
                call    print_message

do_init_return:
                pop     ds
                pop     si
                pop     cx
                retn
do_init         endp


; =============== S U B R O U T I N E =======================================


check_min_reqs  proc near
                mov     si, offset no_vga_mcga_message
                mov     ax, BIOS_VIDEO_GET_DISPLAY_COMBINATION * 256
                int     10h
                ; If this call isn't supported, we don't have a VGA/MCGA BIOS.
                cmp     al, BIOS_VIDEO_GET_DISPLAY_COMBINATION
                jnz     short print_error_message
                mov     si, offset no_dos_3_3_message ; "\r\nGLUECK requires DOS Version 3.30 or"...
                ; Check the DOS version.
                mov     ah, DOS_GET_VERSION
                int     DOS_CALL
                ; Check for 3.x or higher.
                cmp     al, GLUECK_DOS_MAJ_VER
                ; If 4.x or higher, we are successful.
                ja      short successful_min_reqs_check
                ; If 2.x or lower, always failure.
                jb      short print_error_message
                ; If 3.x, check for the minor version being .30 or higher.
                cmp     ah, GLUECK_DOS_MIN_VER
                ; If .30 or higher, we are successful.
                jnb     short successful_min_reqs_check
                ; Otherwise, print the error message.
print_error_message:
                call    print_message
                les     bx, cs:request_header
                ; Tell DOS the size of our driver is zero, which means
                ; not to install it at all.
                mov     word ptr es:[bx+dos_device_request_hdr.request_hdr_address], 0
                ; Set CF to tell do_init we failed.
                stc

successful_min_reqs_check:
                retn
check_min_reqs  endp


; =============== S U B R O U T I N E =======================================


hook_video_parms proc near
                assume  ds:CGROUP
                push    ds
                mov     override_0A, cs ; Alphanumeric Character Set Override pointer segment (set to CS)
                mov     override_0E, cs ; Graphics Character Set Override pointer segment (set to CS)
                mov     font_table_pointer_1_segment, cs ; pointer to character font definition table segment (set to CS)
                mov     font_table_pointer_2_segment, cs ; pointer to character font definition table segment (set to CS)
                mov     ax, seg _BIOS_DATA_SEG
                mov     ds, ax
                assume  ds:_BIOS_DATA_SEG
                les     bx, override_ptr ; BIOS video save/override pointer table address
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
                mov     word ptr override_ptr, offset override_00 ; BIOS video save/override pointer table address
                mov     word ptr override_ptr+2, cs
                pop     ds
                assume  ds:CGROUP
                retn
hook_video_parms endp



; print_message:
;
; Print a null-terminated string in DS:SI, using the
; colour attribute in BL and the page in BH.

print_message   proc near

print_msg_loop: lodsb
                mov     ah, BIOS_VIDEO_WRITE_TTY
                int     BIOS_VIDEO
                cmp     byte ptr [si], 0
                jnz     print_msg_loop
                retn
print_message   endp

INIT_TEXT       ends

; This models the BIOS data segment area at 0040:0000
_BIOS_DATA_SEG  segment para at 40h

                org     49h
current_video_mode      db  ?   ; Current video mode

                org     4ah
num_columns             dw  ?   ; Number of columns in current video mode

                org     4eh
current_page_offset     dw  ?   ; Offset into display memory of the current visible page

                org     62h
current_display_page    db  ?   ; Current page number

                org     84h
num_rows                db  ?   ; Number of rows in current display mode (EGA/VGA/MCGA only)

                org     0A8h
override_ptr            dd  ?   ; Pointer to mode data override area (VGA/MCGA only)

_BIOS_DATA_SEG  ends

                end     devdrvr_hdr_next_drvr
