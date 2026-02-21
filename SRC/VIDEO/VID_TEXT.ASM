; SRC\VIDEO\VID_TEXT.ASM
; --- Salix16 VIDEO TEXT MODULE ---
TITLE SALIX_VID_TEXT
INCLUDE DEFS.INC

.MODEL SMALL
.STACK 100H

.CODE
PUBLIC Vid_Txt_Set_Mode
PUBLIC Vid_Txt_Write_Char
PUBLIC Vid_Txt_Write_String
PUBLIC Vid_Txt_Clear_Screen
PUBLIC Vid_Txt_Set_Attr

; Sets screen the  80x25 16-color Text Mode (03h)
Vid_Txt_Set_Mode PROC
    MOV AX, 0003H               ; BIOS Function 00H, Mode 03H
    INT 10H                     ; Video BIOS Interrupt
    RET 
Vid_Txt_Set_Mode ENDP

; Writes a character to the X, Y Coordinates
; DL = X (0-79), DH = Y (0-24), AL = Char, BL = Color
Vid_Txt_Write_Char PROC
    PUSH ES                     ; Save Segments
    PUSH AX

    ; 1. Point ES to Video Segment
    MOV CX, 0B800H
    MOV ES, CX

    ; 2. Calculate Offset: (Y * 160) + (X * 2)
    ; We'll use a simple approach for TASM 1.0
    MOV AL, DH                  ; AL = Y
    MOV CL, 160                 ; Each row is 160 bytes
    MUL CL                      ; AX = Y 160

    XOR DH, DH                  ; Clear high Byte of X
    SHL DX, 1                   ; DX = X * 2
    ADD AX, DX                  ; AX = Total Offset
    MOV DI, AX                  ; DI is our pointer into Video RAM

    ; Perform the Weld
    POP AX                      ; Restore AL (Char)
    MOV ES:[DI], AL             ; Write Character
    MOV ES:[DI+1], BL           ; Write Attribute (Color)

    POP ES
    RET
Vid_Txt_Write_Char ENDP

; ------------------------------------------------------------
; -- VID_TXT_WRITE_STRING --
; DL=X, DH=Y, BL=Attr, SI=Offset of String (must end in 0)
; ------------------------------------------------------------
; Write a string to the screen
Vid_Txt_Write_String PROC
    PUSH AX
    PUSH BX
    PUSH DX
    PUSH SI
    PUSH DI
    PUSH ES

    ; 1. Set the Video Segment
    MOV AX, 0B800H
    MOV ES, AX

    ; 2. Calculate the Start Offset: (Y * 160) + (X * 2)
    MOV AL, 160
    MUL DH                      ; AX = Y * 160
    MOV DI, AX
    MOV AL, 2
    MUL DL                      ; AX = X * 2
    ADD DI, AX                  ; DI now points to the correct screen memory

String_Loop:
    LODSB                       ; Load character from [SI] into AL, INC SI
    CMP AL, 0                   ; Is it the null terminator?
    JE  Write_Done

    MOV AH, BL                  ; Set the attribute from our register
    STOW                        ; Store har and Attr to [ES:DI], INC DI by 2
    JMP String_Loop

Write_Done:
    POP ES
    POP DI
    POP SI
    POP DX
    POP BX
    POP AX
    RET
Vid_Txt_Write_String ENDP

; Clears the  screen using 0720h (Space char + Light Gray on Black)
; AX = 0720H, CX = 2000 (total characters on 80x25 screen)
Vid_Txt_Clear_Screen PROC
    PUSH ES
    PUSH DI

    MOV AX, 0B800H
    MOV ES, AX                  ; Point ot Video RAM
    XOR DI, DI                  ; Start at the top-Left

    MOV AX, 0720H               ; 07 = Attribute, 20 = Space
    MOV CX, 2000                ; 80 * 25 = 2000 cells
    REP STOSW                   ; The to fill memory fast

    POP DI
    POP ES
    RET    
Vid_Txt_Clear_Screen ENDP

; Sets the attribute (color) of a character at X, Y
; DL = X, DH = Y, BL = Attribute
Vid_Txt_Set_Attr PROC
    PUSH ES
    PUSH DI
    PUSH AX
    MOV AX, 0B800H
    MOV ES, AX                  ; Point to Video RAM

    ; DI = (Y * 160) + (X *2) + 1 <-- The +1 points to the Attribute byte
    ; 1. Calculate Offset
    MOV AL, DH
    MOV AH, 160
    MUL AH                      ; AX = Y * 160

    XOR DH, DH
    MOV DI, DX
    SHL DI, 1                   ; DI = X * 2
    ADD DI, AX                  ; DI = Total Offset
    INC DI                      ; Point to the Attribute byte (DNA of the color)

    ; 2. The Weld: Target the Attribute Byte (Offset + 1)
    MOV ES:[DI+1], BL           ; Apply the new color

    POP AX
    POP DI
    POP ES
    RET    
Vid_Txt_Set_Attr ENDP

END