; PS/2 Model 25/30 BIOS

; Based on 61X8938 and 61X8937 ROM (revision 1, 12/12/86)

BIOS    segment para public 'BIOS'

        org     0

        ; bytes F000:0000 - F000:008F

        db      '61X8938 (C) COPYRIGHT IBM CORPORATION 1981,1987'
        db      '  ALL RIGHTS RESERVED'
        db      '6','6'
        db      '1','1'
        db      'X','X'
        db      '8','8'
        db      '9','9'
        db      '3','3'
        db      '8','7'
        db      '  ((CC))  CCOOPPRR..  IIBBMM  CCOORRPP  11998811,,'
        db      '11998877  '
        db      0fah
        db      0b0h

        org     0e05bh

_entry_point proc far
_entry_point endp
        
        org     0fff0h

_reset  proc    far

        db      0eah        ; JMP FAR
        dw      offset _entry_point, seg BIOS_AT
        db      '12/12/86'  ; BIOS revision date
        db      0           ; Submodel (0FA00h = PS/2 Model 30)
        db      0fah        ; Model (0FAh = PS/2 Model 25 or 30)
;        db      ?           ; Checksum

_reset  endp

BIOS    ends

BIOS_AT segment at 0f000h
BIOS_AT ends

        end
