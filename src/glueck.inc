; This contains helpful constants used by GLUECK.ASM

; The device driver request block.
dos_device_request_hdr  struc
request_hdr_len         db ?    ; Length of this request
request_hdr_subunit     db ?    ; Drive number (not used for character devices)
request_hdr_cmd_code    db ?    ; Command code
request_hdr_status      dw ?    ; Status code on return
request_hdr_reserved    db 9 dup(?)
request_hdr_address     dd ?    ; Address of data for device IOCtl or read/write etc.
request_hdr_count       dw ?    ; Size of data for device IOCtl or read/write etc.
dos_device_request_hdr  ends

; Values for request_hdr_cmd_code
DEV_CMD_INIT    equ     0       ; Initialisation routine
DEV_CMD_IOCTL   equ     0Ch     ; Generic character device IOCtl

; BIOS video
BIOS_VIDEO                          equ 10h
BIOS_VIDEO_SET_MODE                 equ 0
BIOS_VIDEO_WRITE_TTY                equ 0Eh
BIOS_VIDEO_GET_MODE                 equ 0Fh
BIOS_VIDEO_GET_DISPLAY_COMBINATION  equ 1Ah

; DOS calls
DOS_CALL                            equ 21h
DOS_GET_VERSION                     equ 30h

; Number of characters in our fonts
NUM_CHARACTERS                      equ 256

; Name of the device.
GLUECK_DEVICE_NAME                  equ 'HOWARD! '

; Scan lines
VGA_ALPHANUM_400LINES               equ 400
VGA_GRAPHICS_480LINES               equ 480

; Required DOS version
GLUECK_DOS_MAJ_VER                  equ 3
GLUECK_DOS_MIN_VER                  equ 30
