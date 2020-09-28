; PS/2 Model 25/30 BIOS

; Based on 68X1645 and 68X1693 ROM (PS/2 Model 30, revision 0, 9/2/1986)

font8x16_vector equ     3960h
font8x8v_vector equ     4960h
init_vector     equ     0e05bh
font8x8_vector  equ     0fa6eh
rombasic_vector equ     6000h
bios_revision   equ     0
model_code      equ     0fah    ; 0FAh = PS/2 Model 25 or 30
submodel_code   equ     0       ; 0FA00h = PS/2 Model 30
revision_date   equ     '09/02/86'


; Based on 61X8938 and 61X8937 ROM (revision 1, 12/12/86)

BIOS            segment para public 'BIOS'
                assume  cs:BIOS,ds:nothing,es:nothing,ss:nothing

                org     0

                ; F000:0000 - F000:008F

                db      '68X1645 (C) COPYRIGHT IBM CORPORATION 1981,1987'
                db      '  ALL RIGHTS RESERVED'
                db      '6','6'
                db      '8','8'
                db      'X','X'
                db      '1','1'
                db      '6','6'
                db      '4','9'
                db      '5','3'
                db      '  ((CC))  CCOOPPRR..  IIBBMM  CCOORRPP  11998811,,'
                db      '11998877  '
                db      model_code
                db      0b0h
                db      0

                ; F000:0090

                org     init_vector
init_proc       proc far
init_proc       endp

                org     font8x16_vector
                include ../extractors/OLDF8X16.INC
                org     font8x8v_vector
                include ../extractors/FONT8X8V.INC
                org     rombasic_vector
                assume  cs:ROMBASIC_AT,ds:nothing,es:nothing,ss:nothing
                include ../extractors/ROMBASIC.INC
                org     font8x8_vector
                include ../extractors/FONT8X8.INC
                
                org     0fff0h
poweron_proc    proc    far
                assume  cs:POWERON_AT,ds:nothing,es:nothing,ss:nothing

                db      0eah        ; JMP FAR
                dw      offset init_proc, seg ROMBIOS_AT
                db      revision_date   ; BIOS revision date
                db      submodel_code
                db      model_code      
                db      0           ; Checksum

poweron_proc    endp

BIOS            ends

BIOS_AT segment at 0f000h
BIOS_AT ends

ROMBASIC_AT     segment at 0f600h
ROMBASIC_AT     ends

ROMBIOS_AT      segment at 0f000h
ROMBIOS_AT      ends

POWERON_AT      segment at 0ffffh

poweron_vector  equ     $

POWERON_AT      ends

        end
