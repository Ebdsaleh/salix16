; SRC\VIDEO\VID_GEOM.ASM
; --- Salix16 VIDEO TEXT MODE GEOMETRY MODULE ---

TITLE SALIX_VID_GEOM

INCLUDE DEFS.INC
.MODEL SMALL
.STACK 100H

.CODE
PUBLIC Vid_Txt_Draw_HLine
PUBLIC Vid_Txt_Draw_VLine
PUBLIC Vid_Txt_Draw_Rect
PUBLIC Vid_Txt_Draw_Box

; Draws a Horizontal Line
Vid_Txt_Draw_HLine PROC
    PUSH ES
    PUSH DI
    PUSH CX
    PUSH AX
    
    ; 2. Point to Video RAM
    MOV AX, 0B800H
    MOV ES, AX

    ; 2. Calculate Start Offset (Y * 160) + (X * 2)
    MOV AL, DH
    MOV AH, 160
    MUL AH                      ; AX = Y * 160

    XOR DH, DH
    MOV DI, DX
    SHL DI, 1                   ; DI = X* 2
    ADD DI, AX                  ; DI is not the start

    ; 3. The Draw Loop
    POP AX                      ; Restore AL (Char)

H_Loop:
    MOV ES:[DI], AL             ; Write Character
    MOV ES:[DI+1], BL           ; Write Attribute
    ADD DI, 2                   ; Move Right one character
    LOOP H_Loop                 ; Repeat CX times

    POP CX
    POP DI
    POP ES
    RET
Vid_Txt_Draw_HLine ENDP


; Draws a Vertical Line
Vid_Txt_Draw_VLine PROC
    PUSH ES
    PUSH DI
    PUSH CX
    PUSH AX
    
    MOV AX, 0B800H
    MOV ES, AX

    ; Calculate Start Offset
    MOV AL, DH
    MOV AH, 160
    MUL AH
    XOR DH, DH
    MOV DI, DX
    SHL DI, 1
    ADD DI, AX

    POP AX

V_Loop:
    MOV ES:[DI], AL
    MOV ES:[DI+1], BL
    ADD DI, 160                 ; Move DOWN one row (160 bytes)
    LOOP V_Loop

    POP CX
    POP DI
    POP ES
    RET
Vid_Txt_Draw_VLine ENDP


; --- DRAW RECTANGLE (Hollow) ---
; DL=X. DH=Y, CL=Width, CH=Height, AL=Char, BL=Attr
Vid_Txt_Draw_Rect PROC
    PUSH AX
    PUSH CX
    PUSH DX

    ; 1. Top Line
    PUSH CX
    XOR CH, CH                  ; Use only Width for HLine
    CALL Vid_Txt_Draw_HLine
    POP CX

    ; 2. Bottom Line
    PUSH DX
    ADD DH, CH                  ; Move Y down by Height
    DEC DH                      ; Adjust for 0-Index
    PUSH CX
    XOR CH, CH
    CALL Vid_Txt_Draw_HLine
    POP CX
    POP DX

    ; 3. Left Line
    PUSH CX
    MOV CL, CH                  ; Move Height Int CL for VLine
    XOR CH, CH
    CALL Vid_Txt_Draw_VLine
    POP CX

    ; 4. Right Line
    PUSH DX
    ADD DL, CL                  ; Move X Right by Width
    DEC DL                      ; Adjust for 0-index
    
    PUSH CX
    MOV CL, CH               ; Move Height into CL for VLine
    XOR CH, CH
    CALL Vid_Txt_Draw_VLine

    POP CX
    POP DX 
    ; Safely POP the stack
    POP DX                      
    POP CX                      
    POP AX                             
    RET
Vid_Txt_Draw_Rect ENDP

; --- DRAW BOX (Filled) ---
; DL=x, DH=Y, CL=Width, AL=Char, BL=Attr
Vid_Txt_Draw_Box PROC
    PUSH DX                     ; Save original X/Y
    PUSH CX                     ; Save original W/H
    PUSH AX                     ; Save original character/attribute

Row_Loop:
    PUSH DX                     ; Save current X/Y
    PUSH CX                     ; Save current Height counter

    ; --- Draw one Horizontal Line ---
    ; We need to move the width into CX for the HLine call
    MOV CH, 0                   ; Make CX purely the Width (CL)
    CALL Vid_Txt_Draw_HLine

    ; --- Restore state for the next iteration ---
    POP CX                      ; Restore W/H
    POP DX                      ; Restore X/Y

    INC DH                      ; Move to next Row
    DEC CH                      ; One row finished
    JNZ Row_Loop                ; If CH is not 0, do next row

    POP AX
    POP CX
    POP DX
    RET
Vid_Txt_Draw_Box ENDP

END