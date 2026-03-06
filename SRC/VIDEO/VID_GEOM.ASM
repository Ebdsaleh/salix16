; SRC\VIDEO\VID_GEOM.ASM
; --- Salix16 VIDEO TEXT MODE GEOMETRY MODULE ---

TITLE SALIX_VID_GEOM

.MODEL SMALL

INCLUDE DEFS.INC

.CODE
PUBLIC Vid_Txt_Draw_HLine
PUBLIC Vid_Txt_Draw_VLine
PUBLIC Vid_Txt_Draw_Rect
PUBLIC Vid_Txt_Draw_Box

; --- VID_TXT_DRAW_HLINE ---
; DL=X, DH=Y, CL=Height, AL=Char, BL=Attr
; Draws a Horizontal Line
Vid_Txt_Draw_HLine PROC NEAR
    PUSH ES
    PUSH DI
    PUSH SI
    PUSH CX
    PUSH AX
    PUSH DX                     ; Protect original X/Y

    ; 2. Point to Video RAM
    MOV AX, 0B800H
    MOV ES, AX

    ; 2. Calculate Start Offset (Y * 160) + (X * 2)
    ; First offset: Y * 160
    MOV AX, 0                   ; Clear AX
    MOV AL, DH                  ; Get Y
    MOV CL, 160
    MUL CL                      ; AX = Y * 160
    ; Use a temporary register (DI) for X-Maths to keep DX clean
    MOV DI, AX                  ; Store Y-offset in DI

    ; Second offset: X * 2
    MOV AH, 0                   ; Ensure AH is Clean
    MOV AK, DL                  ; Get only X
    SHL AX, 1                   ; AX = X * 2

    ; Combine them
    ADD DI, AX                  ; DI = (Y * 160) + (X *  2)

    ; 3. Draw the line 
    ; We need the width in CX for the LOOP instruction
    POP DX                      ; Get original DX (X/Y) back for safety
    POP AX                      ; Restore AL (Char) and AH (which we'll ignore)
    POP CX                      ; Get original CX (Width) back
    
    PUSH CX                     ; Put them back on the stack so the final POP's work OK
    PUSH AX
    PUSH DX
    
    ; Ensure CX only contains the width (CL)
    MOV CH, 0
    JCXZ HLine_Done             ; If width is 0, don't even start

H_Loop:
    MOV ES:[DI], AL             ; Write Character
    MOV ES:[DI+1], BL           ; Write Attribute
    ADD DI, 2                   ; Move Right one character
    LOOP H_Loop                 ; Repeat CX times

    ; 4. Clean up the stack in PERFECT reverse order.
HLine_Done:
    POP DX
    POP AX
    POP CX
    POP SI
    POP DI
    POP ES
    RET
Vid_Txt_Draw_HLine ENDP
; -----------------------------------------------------------

; --- VID_TXT_DRAW_VLINE ---
; DL=X, DH=Y, CL=Height, AL=Char, BL=Attr
; Draws a Vertical Line
Vid_Txt_Draw_VLine PROC NEAR
    PUSH ES
    PUSH DI
    PUSH CX
    PUSH AX
    PUSH DX                     ; Protect original X/Y

    MOV AX, 0B800H
    MOV ES, AX

    ; Calculate Start Offset
    ; This is where we isloate DL and DH to prevent drifting
    ; Use 8-bit maths
    MOV AL, DH                  ; Get Y
    MOV CL, 160
    MUL CL                      ; CX = Y * 160
    MOV DI, AX                  ; DI = Y-offset
    
    MOV AL, DL                  ; Get ONLY X
    MOV AH, 0
    SHL AX, 1                   ; AX = X * 2
    
    ADD DI, AX                  ; DI is now the perfect starting memory address

    ; 3. Draw the Vertical Line

    POP DX                      ; Restore X/Y
    POP AX                      ; Restore Char/Attr
    POP CX

    PUSH CX
    PUSH AX                     
    PUSH DX                     
    MOV CH, 0                   ; Ensure CX is Just the Height (CL) 
    JCXZ VLine_Done

V_Loop:
    MOV ES:[DI], AL             ; Write Char
    MOV ES:[DI+1], BL           ; Write Attr
    ADD DI, 160                 ; Move DOWN one row (160 bytes)
    LOOP V_Loop

VLine_Done:
    ; 4. Clean up the stack
    POP DX
    POP AX
    POP CX
    POP DI
    POP ES
    RET
Vid_Txt_Draw_VLine ENDP
; ---------------------------------------------------------------------

; --- DRAW RECTANGLE (Hollow) ---
; DL=X. DH=Y, CL=Width, CH=Height, AL=Char, BL=Attr
Vid_Txt_Draw_Rect PROC
    PUSH DX
    PUSH CX
    PUSH AX

    ; 1. Top Line
    PUSH CX
    MOV CH, 0                   ; Use only Width for HLine
    CALL Vid_Txt_Draw_HLine
    POP CX

    ; 2. Bottom Line
    PUSH DX
    ADD DH, CH                  ; Move Y down by Height
    DEC DH                      ; Adjust for 0-Index
    PUSH CX
    MOV CH, 0
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
    MOV CL, CH               ; Move Height into CL for VLine
    CALL Vid_Txt_Draw_VLine

    POP DX 
    ; Safely POP the stack
    POP AX                      
    POP CX                      
    POP DX                             
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