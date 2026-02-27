; SRC\VIDEO\VID_COMP.ASM
; --- Salix16 VIDEO THEM MODE COMPONENTS MODULE ---
TITLE SALIX_VID_COMP

.MODEL SMALL

INCLUDE DEFS.INC

.DATA
    ; Style Set Guide:          TL      TR      BL      BR      Horiz   Vert
    ; Single Line Set:
    Set_Single          DB      218,    191,    192,    217,    196,    179
    ; Double Line Set:
    Set_Double          DB      201,    187,    200,    188,    205,    186        

.CODE
PUBLIC Vid_Txt_Draw_Border
PUBLIC Vid_Txt_Draw_Panel

EXTRN Vid_Txt_Write_Char:PROC
EXTRN Vid_Txt_Draw_HLine:PROC
EXTRN Vid_Txt_Draw_VLine:PROC
EXTRN Vid_Txt_Draw_Box:PROC
EXTRN Vid_Txt_Draw_Rect:PROC


; ----------------------------------------------------------------
; --- VID_TXT_DRAW_BORDER --
; DL=X, DH=Y, CL=W, BL=Attr, SI=Offset to Style Set
; ----------------------------------------------------------------
Vid_Txt_Draw_Border PROC
    PUSH AX
    PUSH CX
    PUSH DX

    ; --- 1. THE TOP ROW ---
    ; Draw the Top-Left Corner
    MOV AL, [SI+0]              ; Select TL character from the set
    CALL Vid_Txt_Write_Char     ; Write it to X, Y

    ; Draw Top Horizontal Wall  
    PUSH DX
    PUSH CX
    INC DL                      ; Move X right by 1 so we don't overwrite the corners
    SUB CL, 2                   ; Shrink width by 2 (for both corners)
    MOV AL. [SI+4]              ; Select Horizontal character
    XOR BH, BH                  ; Clear BH for safety
    MOV CH, 0                   ; TASM 1.0 Ensure CX is just the width
    CALL Vid_Txt_Draw_HLine     ; Draw the top bar
    POP CX
    POP DX

    ; Draw Top-Right Corner
    PUSH DX
    ADD DL, CL                  ; Move X to the far-right
    DEC DL                      ; Adjust for 0-index
    MOV AL, [SI+1]              ; Select the TR character
    CALL Vid_Txt_Write_Char     ; Write it

    ; --- 2. THE BOTTOM ROW ---
    ; Move Y down to the very last row
    PUSH DX
    XOR AX, AX
    MOV AL, CH                  ; Move Height to AL
    ADD DH, AL                  ; Move Y down by the Height value
    DEC DH                      ; Adjust for 0-index

    ; Draw Bottom-Left Corner
    MOV AL, [SI+2]              ; Select BL character
    CALL Vid_Txt_Write_Char     ; Write it

    PUSH DX
    PUSH CX
    INC DL
    SUB CL, 2
    MOV AL, [SI+4]              ; Horizontal
    MOV CH, 0
    CALL Vid_Txt_Draw_HLine
    POP CX
    POP DX

    ; Draw Bottom-Right Corner
    PUSH DX
    ADD DL, CL                  ; Move X to the far-right
    DEC DL                      ; Adjust for 0-index
    MOV AL, [SI+3]              ; Select the BR character
    CALL Vid_Txt_Write_Char     ; Write it
    POP DX
    POP DX

    ; --- 3. THE SIDE WALLS
    ; Draw Left Vertical Wall
    PUSH DX
    INC DH                      ; Start 1 row down from the top corner
    MOV AL, [SI+5]              ; Select the Vertical character
    PUSH CX
    MOV CL, CH                  ; Move Height into CX for the loop
    SUB CL, 2                   ; Subtract 2 rows (Top and Bottom corners)
    XOR CH, CH
    CALL Vid_Txt_Draw_VLine     ; Draw the left bar
    POP CX
    POP DX

    ; Draw Right Vertical Wall
    PUSH DX
    PUSH CX
    ADD DL, CL                  ; Move X to the far-right
    DEC DL                      ; Adjust for 0-index
    INC DH                      ; Start 1 row down
    MOV CL, CH                  ; Move Height into CX
    SUB CL, 2                   ; Subtract corners
    MOV AL, [SI+5]              ; Select The Vertical character
    CALL Vid_Txt_Draw_VLine     ; Draw the right bar
    POP CX
    POP DX

    POP DX
    POP CX
    POP AX
    RET
Vid_Txt_Draw_Border ENDP


; --- VID_TXT_DRAW_PANEL ---
; DL=X, DH=Y, CL=W, BL=Attr, BH=Style
; Style: 0=None, 1=Single, 2=Double
Vid_Txt_Draw_Panel PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI


    ; 1. Draw the Background (The "Floor")
    PUSH CX                     ; Save original Width/Height
    PUSH DX                     ; Save original X/Y
    PUSH AX
    MOV AL, ' '                 ; Fill with Space
    CALL Vid_Txt_Draw_Box

    POP DX                      ; Restore X/Y for the border logic
    POP CX                      ; Restore W/H for the border logic

    ; 2. Check Style for Borders
    CMP BH, 1
    JE Style_1             ; Single Border
    CMP BH, 2
    JE Style_2             ; Double Border

Style_1:
    ; Use Single Line Chars (0DAH, 0BFH, 0C0H, 0D9H, 0C4H, 0B3H)
    ; For Brevity, we'll call our Rect routine with the 'H' line Character
    ; MOV AL, 0C4H                ; '-'
    LEA SI, Set_Single          ; Point SI to the Single-Line DNA 
    CALL Vid_Txt_Draw_Border
    JMP Panel_Done
Style_2:
    ; Use Double Line Chars (0C9H, 0BBH, 0C8H, 0CDH, 0BAH)
    ;MOV AL, 0CDH                ; '='
    LEA SI, Set_Double          ; Point SI to the Double-Line DNA
    CALL Vid_Txt_Draw_Border

Panel_Done:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
Vid_Txt_Draw_Panel ENDP

END