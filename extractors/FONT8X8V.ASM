                name    FONT8X8V
            
; Typically placed at F000:4A30 - F000:512F
            
BIOS_BIOS_FONT8X8V     segment byte public 'BIOS_ROM'


                db 0,0,0,0,0,0,0,0                     ; CHR$(0)
                db 126,129,165,129,189,153,129,126     ; CHR$(1)
                db 126,255,219,255,195,231,255,126     ; CHR$(2)
                db 108,254,254,254,124,56,16,0         ; CHR$(3)
                db 16,56,124,254,124,56,16,0           ; CHR$(4)
                db 56,124,56,254,254,124,56,124        ; CHR$(5)
                db 16,16,56,124,254,124,56,124         ; CHR$(6)
                db 0,0,24,60,60,24,0,0                 ; CHR$(7)
                db 255,255,231,195,195,231,255,255     ; CHR$(8)
                db 0,60,102,66,66,102,60,0             ; CHR$(9)
                db 255,195,153,189,189,153,195,255     ; CHR$(10)
                db 15,7,15,125,204,204,204,120         ; CHR$(11)
                db 60,102,102,102,60,24,126,24         ; CHR$(12)
                db 63,51,63,48,48,112,240,224          ; CHR$(13)
                db 127,99,127,99,99,103,230,192        ; CHR$(14)
                db 153,90,60,231,231,60,90,153         ; CHR$(15)
                db 128,224,248,254,248,224,128,0       ; CHR$(16)
                db 2,14,62,254,62,14,2,0               ; CHR$(17)
                db 24,60,126,24,24,126,60,24           ; CHR$(18)
                db 102,102,102,102,102,0,102,0         ; CHR$(19)
                db 127,219,219,123,27,27,27,0          ; CHR$(20)
                db 62,99,56,108,108,56,204,120         ; CHR$(21)
                db 0,0,0,0,126,126,126,0               ; CHR$(22)
                db 24,60,126,24,126,60,24,255          ; CHR$(23)
                db 24,60,126,24,24,24,24,0             ; CHR$(24)
                db 24,24,24,24,126,60,24,0             ; CHR$(25)
                db 0,24,12,254,12,24,0,0               ; CHR$(26)
                db 0,48,96,254,96,48,0,0               ; CHR$(27)
                db 0,0,192,192,192,254,0,0             ; CHR$(28)
                db 0,36,102,255,102,36,0,0             ; CHR$(29)
                db 0,24,60,126,255,255,0,0             ; CHR$(30)
                db 0,255,255,126,60,24,0,0             ; CHR$(31)
                db 0,0,0,0,0,0,0,0                     ; " " ' (a space)
                db 48,120,120,48,48,0,48,0             ; "!"
                db 108,108,108,0,0,0,0,0               ; CHR$(34) ' (a " character)
                db 108,108,254,108,254,108,108,0       ; "#"
                db 48,124,192,120,12,248,48,0          ; "$"
                db 0,198,204,24,48,102,198,0           ; "%"
                db 56,108,56,118,220,204,118,0         ; "&"
                db 96,96,192,0,0,0,0,0                 ; "'"
                db 24,48,96,96,96,48,24,0              ; "("
                db 96,48,24,24,24,48,96,0              ; ")"
                db 0,102,60,255,60,102,0,0             ; "*"
                db 0,48,48,252,48,48,0,0               ; "+"
                db 0,0,0,0,0,48,48,96                  ; ","
                db 0,0,0,252,0,0,0,0                   ; "-"
                db 0,0,0,0,0,48,48,0                   ; "."
                db 6,12,24,48,96,192,128,0             ; "/"
                db 124,198,206,222,246,230,124,0       ; "0"
                db 48,112,48,48,48,48,252,0            ; "1"
                db 120,204,12,56,96,204,252,0          ; "2"
                db 120,204,12,56,12,204,120,0          ; "3"
                db 28,60,108,204,254,12,30,0           ; "4"
                db 252,192,248,12,12,204,120,0         ; "5"
                db 56,96,192,248,204,204,120,0         ; "6"
                db 252,204,12,24,48,48,48,0            ; "7"
                db 120,204,204,120,204,204,120,0       ; "8"
                db 120,204,204,124,12,24,112,0         ; "9"
                db 0,48,48,0,0,48,48,0                 ; ":"
                db 0,48,48,0,0,48,48,96                ; ";"
                db 24,48,96,192,96,48,24,0             ; "<"
                db 0,0,252,0,0,252,0,0                 ; "="
                db 96,48,24,12,24,48,96,0              ; ">"
                db 120,204,12,24,48,0,48,0             ; "?"
                db 124,198,222,222,222,192,120,0       ; "@"
                db 48,120,204,204,252,204,204,0        ; "A"
                db 252,102,102,124,102,102,252,0       ; "B"
                db 60,102,192,192,192,102,60,0         ; "C"
                db 248,108,102,102,102,108,248,0       ; "D"
                db 254,98,104,120,104,98,254,0         ; "E"
                db 254,98,104,120,104,96,240,0         ; "F"
                db 60,102,192,192,206,102,62,0         ; "G"
                db 204,204,204,252,204,204,204,0       ; "H"
                db 120,48,48,48,48,48,120,0            ; "I"
                db 30,12,12,12,204,204,120,0           ; "J"
                db 230,102,108,120,108,102,230,0       ; "K"
                db 240,96,96,96,98,102,254,0           ; "L"
                db 198,238,254,254,214,198,198,0       ; "M"
                db 198,230,246,222,206,198,198,0       ; "N"
                db 56,108,198,198,198,108,56,0         ; "O"
                db 252,102,102,124,96,96,240,0         ; "P"
                db 120,204,204,204,220,120,28,0        ; "Q"
                db 252,102,102,124,108,102,230,0       ; "R"
                db 120,204,224,112,28,204,120,0        ; "S"
                db 252,180,48,48,48,48,120,0           ; "T"
                db 204,204,204,204,204,204,252,0       ; "U"
                db 204,204,204,204,204,120,48,0        ; "V"
                db 198,198,198,214,254,238,198,0       ; "W"
                db 198,198,108,56,56,108,198,0         ; "X"
                db 204,204,204,120,48,48,120,0         ; "Y"
                db 254,198,140,24,50,102,254,0         ; "Z"
                db 120,96,96,96,96,96,120,0            ; "["
                db 192,96,48,24,12,6,2,0               ; "\"
                db 120,24,24,24,24,24,120,0            ; "]"
                db 16,56,108,198,0,0,0,0               ; "^"
                db 0,0,0,0,0,0,0,255                   ; "_"
                db 48,48,24,0,0,0,0,0                  ; "`"
                db 0,0,120,12,124,204,118,0            ; "a"
                db 224,96,96,124,102,102,220,0         ; "b"
                db 0,0,120,204,192,204,120,0           ; "c"
                db 28,12,12,124,204,204,118,0          ; "d"
                db 0,0,120,204,252,192,120,0           ; "e"
                db 56,108,96,240,96,96,240,0           ; "f"
                db 0,0,118,204,204,124,12,248          ; "g"
                db 224,96,108,118,102,102,230,0        ; "h"
                db 48,0,112,48,48,48,120,0             ; "i"
                db 12,0,12,12,12,204,204,120           ; "j"
                db 224,96,102,108,120,108,230,0        ; "k"
                db 112,48,48,48,48,48,120,0            ; "l"
                db 0,0,204,254,254,214,198,0           ; "m"
                db 0,0,248,204,204,204,204,0           ; "n"
                db 0,0,120,204,204,204,120,0           ; "o"
                db 0,0,220,102,102,124,96,240          ; "p"
                db 0,0,118,204,204,124,12,30           ; "q"
                db 0,0,220,118,102,96,240,0            ; "r"
                db 0,0,124,192,120,12,248,0            ; "s"
                db 16,48,124,48,48,52,24,0             ; "t"
                db 0,0,204,204,204,204,118,0           ; "u"
                db 0,0,204,204,204,120,48,0            ; "v"
                db 0,0,198,214,254,254,108,0           ; "w"
                db 0,0,198,108,56,108,198,0            ; "x"
                db 0,0,204,204,204,124,12,248          ; "y"
                db 0,0,252,152,48,100,252,0            ; "z"
                db 28,48,48,224,48,48,28,0             ; "{"
                db 24,24,24,0,24,24,24,0               ; "|"
                db 224,48,48,28,48,48,224,0            ; "}"
                db 118,220,0,0,0,0,0,0                 ; "~"
                db 0,16,56,108,198,198,254,0           ; CHR$(127)
                db 120,204,192,204,120,24,12,120       ; CHR$(128)
                db 0,204,0,204,204,204,126,0           ; CHR$(129)
                db 28,0,120,204,252,192,120,0          ; CHR$(130)
                db 126,195,60,6,62,102,63,0            ; CHR$(131)
                db 204,0,120,12,124,204,126,0          ; CHR$(132)
                db 224,0,120,12,124,204,126,0          ; CHR$(133)
                db 48,48,120,12,124,204,126,0          ; CHR$(134)
                db 0,0,120,192,192,120,12,56           ; CHR$(135)
                db 126,195,60,102,126,96,60,0          ; CHR$(136)
                db 204,0,120,204,252,192,120,0         ; CHR$(137)
                db 224,0,120,204,252,192,120,0         ; CHR$(138)
                db 204,0,112,48,48,48,120,0            ; CHR$(139)
                db 124,198,56,24,24,24,60,0            ; CHR$(140)
                db 224,0,112,48,48,48,120,0            ; CHR$(141)
                db 198,56,108,198,254,198,198,0        ; CHR$(142)
                db 48,48,0,120,204,252,204,0           ; CHR$(143)
                db 28,0,252,96,120,96,252,0            ; CHR$(144)
                db 0,0,127,12,127,204,127,0            ; CHR$(145)
                db 62,108,204,254,204,204,206,0        ; CHR$(146)
                db 120,204,0,120,204,204,120,0         ; CHR$(147)
                db 0,204,0,120,204,204,120,0           ; CHR$(148)
                db 0,224,0,120,204,204,120,0           ; CHR$(149)
                db 120,204,0,204,204,204,126,0         ; CHR$(150)
                db 0,224,0,204,204,204,126,0           ; CHR$(151)
                db 0,204,0,204,204,124,12,248          ; CHR$(152)
                db 195,24,60,102,102,60,24,0           ; CHR$(153)
                db 204,0,204,204,204,204,120,0         ; CHR$(154)
                db 24,24,126,192,192,126,24,24         ; CHR$(155)
                db 56,108,100,240,96,230,252,0         ; CHR$(156)
                db 204,204,120,252,48,252,48,48        ; CHR$(157)
                db 248,204,204,250,198,207,198,199     ; CHR$(158)
                db 14,27,24,60,24,24,216,112           ; CHR$(159)
                db 28,0,120,12,124,204,126,0           ; CHR$(160)
                db 56,0,112,48,48,48,120,0             ; CHR$(161)
                db 0,28,0,120,204,204,120,0            ; CHR$(162)
                db 0,28,0,204,204,204,126,0            ; CHR$(163)
                db 0,248,0,248,204,204,204,0           ; CHR$(164)
                db 252,0,204,236,252,220,204,0         ; CHR$(165)
                db 60,108,108,62,0,126,0,0             ; CHR$(166)
                db 56,108,108,56,0,124,0,0             ; CHR$(167)
                db 48,0,48,96,192,204,120,0            ; CHR$(168)
                db 0,0,0,252,192,192,0,0               ; CHR$(169)
                db 0,0,0,252,12,12,0,0                 ; CHR$(170)
                db 195,198,204,222,51,102,204,15       ; CHR$(171)
                db 195,198,204,219,55,111,207,3        ; CHR$(172)
                db 24,24,0,24,24,24,24,0               ; CHR$(173)
                db 0,51,102,204,102,51,0,0             ; CHR$(174)
                db 0,204,102,51,102,204,0,0            ; CHR$(175)
                db 34,136,34,136,34,136,34,136         ; CHR$(176)
                db 85,170,85,170,85,170,85,170         ; CHR$(177)
                db 219,119,219,238,219,119,219,238     ; CHR$(178)
                db 24,24,24,24,24,24,24,24             ; CHR$(179)
                db 24,24,24,24,248,24,24,24            ; CHR$(180)
                db 24,24,248,24,248,24,24,24           ; CHR$(181)
                db 54,54,54,54,246,54,54,54            ; CHR$(182)
                db 0,0,0,0,254,54,54,54                ; CHR$(183)
                db 0,0,248,24,248,24,24,24             ; CHR$(184)
                db 54,54,246,6,246,54,54,54            ; CHR$(185)
                db 54,54,54,54,54,54,54,54             ; CHR$(186)
                db 0,0,254,6,246,54,54,54              ; CHR$(187)
                db 54,54,246,6,254,0,0,0               ; CHR$(188)
                db 54,54,54,54,254,0,0,0               ; CHR$(189)
                db 24,24,248,24,248,0,0,0              ; CHR$(190)
                db 0,0,0,0,248,24,24,24                ; CHR$(191)
                db 24,24,24,24,31,0,0,0                ; CHR$(192)
                db 24,24,24,24,255,0,0,0               ; CHR$(193)
                db 0,0,0,0,255,24,24,24                ; CHR$(194)
                db 24,24,24,24,31,24,24,24             ; CHR$(195)
                db 0,0,0,0,255,0,0,0                   ; CHR$(196)
                db 24,24,24,24,255,24,24,24            ; CHR$(197)
                db 24,24,31,24,31,24,24,24             ; CHR$(198)
                db 54,54,54,54,55,54,54,54             ; CHR$(199)
                db 54,54,55,48,63,0,0,0                ; CHR$(200)
                db 0,0,63,48,55,54,54,54               ; CHR$(201)
                db 54,54,247,0,255,0,0,0               ; CHR$(202)
                db 0,0,255,0,247,54,54,54              ; CHR$(203)
                db 54,54,55,48,55,54,54,54             ; CHR$(204)
                db 0,0,255,0,255,0,0,0                 ; CHR$(205)
                db 54,54,247,0,247,54,54,54            ; CHR$(206)
                db 24,24,255,0,255,0,0,0               ; CHR$(207)
                db 54,54,54,54,255,0,0,0               ; CHR$(208)
                db 0,0,255,0,255,24,24,24              ; CHR$(209)
                db 0,0,0,0,255,54,54,54                ; CHR$(210)
                db 54,54,54,54,63,0,0,0                ; CHR$(211)
                db 24,24,31,24,31,0,0,0                ; CHR$(212)
                db 0,0,31,24,31,24,24,24               ; CHR$(213)
                db 0,0,0,0,63,54,54,54                 ; CHR$(214)
                db 54,54,54,54,255,54,54,54            ; CHR$(215)
                db 24,24,255,24,255,24,24,24           ; CHR$(216)
                db 24,24,24,24,248,0,0,0               ; CHR$(217)
                db 0,0,0,0,31,24,24,24                 ; CHR$(218)
                db 255,255,255,255,255,255,255,255     ; CHR$(219)
                db 0,0,0,0,255,255,255,255             ; CHR$(220)
                db 240,240,240,240,240,240,240,240     ; CHR$(221)
                db 15,15,15,15,15,15,15,15             ; CHR$(222)
                db 255,255,255,255,0,0,0,0             ; CHR$(223)
                db 0,0,118,220,200,220,118,0           ; CHR$(224)
                db 0,120,204,248,204,248,192,192       ; CHR$(225)
                db 0,252,204,192,192,192,192,0         ; CHR$(226)
                db 0,254,108,108,108,108,108,0         ; CHR$(227)
                db 252,204,96,48,96,204,252,0          ; CHR$(228)
                db 0,0,126,216,216,216,112,0           ; CHR$(229)
                db 0,102,102,102,102,124,96,192        ; CHR$(230)
                db 0,118,220,24,24,24,24,0             ; CHR$(231)
                db 252,48,120,204,204,120,48,252       ; CHR$(232)
                db 56,108,198,254,198,108,56,0         ; CHR$(233)
                db 56,108,198,198,108,108,238,0        ; CHR$(234)
                db 28,48,24,124,204,204,120,0          ; CHR$(235)
                db 0,0,126,219,219,126,0,0             ; CHR$(236)
                db 6,12,126,219,219,126,96,192         ; CHR$(237)
                db 56,96,192,248,192,96,56,0           ; CHR$(238)
                db 120,204,204,204,204,204,204,0       ; CHR$(239)
                db 0,252,0,252,0,252,0,0               ; CHR$(240)
                db 48,48,252,48,48,0,252,0             ; CHR$(241)
                db 96,48,24,48,96,0,252,0              ; CHR$(242)
                db 24,48,96,48,24,0,252,0              ; CHR$(243)
                db 14,27,27,24,24,24,24,24             ; CHR$(244)
                db 24,24,24,24,24,216,216,112          ; CHR$(245)
                db 48,48,0,252,0,48,48,0               ; CHR$(246)
                db 0,118,220,0,118,220,0,0             ; CHR$(247)
                db 56,108,108,56,0,0,0,0               ; CHR$(248)
                db 0,0,0,24,24,0,0,0                   ; CHR$(249)
                db 0,0,0,0,24,0,0,0                    ; CHR$(250)
                db 15,12,12,12,236,108,60,28           ; CHR$(251)
                db 120,108,108,108,108,0,0,0           ; CHR$(252)
                db 112,24,48,96,120,0,0,0              ; CHR$(253)
                db 0,0,60,60,60,60,0,0                 ; CHR$(254)
                db 0,0,0,0,0,0,0,0                     ; CHR$(255)

BIOS_BIOS_FONT8X8V     ends

                end
