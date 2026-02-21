; SRC\VIDEO\VID_COMP.ASM
; --- Salix16 VIDEO THEM MODE COMPONENTS MODULE ---
TITLE SALIX_VID_COMP
INCLUDE DEFS.INC

.MODEL SMALL
.STACK 100H

.CODE
PUBLIC Vid_Txt_Draw_Panel
EXTRN Vid_Txt_Draw_Box
EXTRN Vid_Txt_Draw_Rect

; --- VID_TXT_DRAW_PANEL ---
; DL=X, DH=Y, CL=W, BL=Attr, BH=Style
; Style: 0=None, 1=Single, 2=Double
Vid_Txt_Draw_Panel PROC
    PUSH AX
    PUSH CX
    PUSH DX

    ; 1. Draw the Background (The "Floor")
    PUSH CX                     ; Save original Width/Height
    PUSH DX                     ; Save original X/Y
    MOV AL, ' '                 ; Fill with Space
    CALL Vid_Txt_Draw_Box

    POP DX                      ; Restore X/Y for the border logic
    POP CX                      ; Restore W/H for the border logic

    ; 2. Check Style for Borders
    CMP BH, 0
    JE Panel_Done               ; No border requested

    CMP BH, 1
    JE Style_Single             ; Single Border

    CMP BH, 2
    JE Style_Double             ; Double Border

Style_Single:
    ; Use Single Line Chars (0DAH, 0BFH, 0C0H, 0D9H, 0C4H, 0B3H)
    ; For Brevity, we'll call our Rect routine with the 'H' line Character
    MOV AL, 0C4H                ; '-'
    JMP Draw_Border

Style_Double:
    ; Use Double Line Chars (0C9H, 0BBH, 0C8H, 0CDH, 0BAH)
    MOV AL, 0CDH                ; '='
    JMP Draw_Border

Draw_Border:
    CALL Vid_Txt_Draw_Rect

Panel_Done:
    POP DX
    POP CX
    POP AX
    RET
Vid_Txt_Draw_Panel ENDP

END