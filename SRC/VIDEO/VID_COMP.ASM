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
; DL=X, DH=Y, CL=W, CH=H, BL=Attr, SI=Offset to Style Set
; ----------------------------------------------------------------
Vid_Txt_Draw_Border PROC NEAR
    PUSH DX
    PUSH CX
    PUSH AX

    ; --- THE START-POSTION GUARD (SAFE LIMITS) ---
    CMP DL, 77                  ; MAX Start X
    JBE DL_OK
    JMP Border_Exit             ; If DL > 77, Abort

; X position under 78
DL_OK:
    CMP DH, 22                  ; MAX Start Y
    JBE DH_OK
    JMP Border_Exit             ; If DH > 22, Abort

; Y position under 22
DH_OK:
    ; --- THE MASTER SIZE GUARD ---
    CMP CL, 2                   ; Is width < 2?
    JNB CL_OK                   
    JMP Border_Exit             ; If yes, don't draw anything

; Width 2+
CL_OK:
    CMP CH, 2                   ; Is Height < 2?
    JNB CH_OK
    JMP Border_Exit             ; If yes, exit             

; Height 2+
CH_OK:

    ; --- PHASE 1: THE FOUR CORNERS ---

    ; --- DRAW THE TOP ROW ---
    ; Draw the Top-Left (TL) Corner
    ; MOV AX, 0                 ; Clear AX
    MOV AL, [SI+0]              ; Select the TL char
    CALL Vid_Txt_Write_Char     ; Draw at X, Y (DL, DH)

    ; --- Draw the Top-Right (TR) Corner ---
    PUSH DX
    ; Calculate TR X ONLY:
    MOV AX, 0                   ; Clear AX for 8-bit maths
    MOV AL, DL                  ; Get Current X
    ADD AL, CL                  ; Add Width (0 + 2 = 2)

    ; --- THE TR CLAMP ---
    CMP AL, 79                  ; Is the result off-screen?
    JBE TR_Ready                ; If AL <- 79, it is safe
    MOV AL, 79                  ; Force to the last column (0-79)

TR_Ready:
    MOV DL, AL                  ; Update DL for the call
    MOV AL, [SI+1]              ; Get Style TR character
    CALL Vid_Txt_Write_Char     ; Draw TR at (Safe_X, DH)
    POP DX                      ; Restore original X, Y

    ; --- Bottom-Left (BL) Corner ---
    PUSH DX
    MOV AX, 0                   ; Clear AX
    MOV AL, DH                  ; AL = Start Y
    ADD AL, CH                  ; AL = Start Y + Height

    ; --- THE BL CLAMP ---
    CMP AL, 24                  ; Is the result below the screen?
    JBE BL_Ready                ; If AL <= 24, it's safe
    MOV AL, 24                  ; Force to the very last row

BL_Ready:
    MOV DH, AL                  ; Update DH with the safe Y Coordinate
    MOV AL, [SI+2]              ; Get BL Char from Style Set
    CALL Vid_Txt_Write_Char     ; Draw BL at (original_X, Safe_y)
    POP DX

    ; --- Bottom Right (BR) Corner ---
    PUSH DX
    ; Calculate X
    MOV AX, 0                   ; Clear AX
    MOV AL, DL                  ; AL = X
    ADD AL, CL                  ; AL = X + Width

    ; --- THE BR CLAMP ---
    CMP AL, 79                  ; Is the result below 79 MAx right-side-X
    JBE BR_X_Ready
    MOV AL, 79

BR_X_Ready:
    MOV DL, AL
    ; Calculate Y
    MOV AL, DH
    ADD AL, CH 
    CMP AL, 24                  ; Is the result below 24
    JBE BR_Y_Ready
    MOV AL, 24

BR_Y_Ready:
    MOV DH, AL
    MOV AL, [SI+3]   ; BR Character 
    CALL Vid_Txt_Write_Char     ; Write BR char,  the final corner character.
    POP DX
    ; --- END OF PHASE 1 ---

    ; ---  PHASE 2: HORIZONTAL WALLS (=) ---
    ; --- TOP WALL ---
    PUSH DX                     ; Save original X,Y

    ; Calculate Start position (X +1, Y)
    INC DL                      ; Move X 1 column to the right
    SUB CL, 1                   ; Trim the length by 1 so we don't overwrite the corner char

    MOV AL, CL                  ; Get Width
    DEC AL                      ; Length is Width minus the Starting corner
    JZ Skip_Top_H               ; If Width was exactly 1, no gap to fill
    MOV AH, AL                  ; Put length into AH
    MOV AL, [SI+4]              ; Get Horizontal char
    CALL Vid_Txt_Draw_HLine     ; Draw the top bar

Skip_Top_H:
    POP DX

    ; --- BOTTOM WALL ---
    PUSH DX
    ; Calculate the Bottom Y (same logic as the BL/BR)
    MOV AL, DH
    ADD AL, CH
    CMP AL, 24                  ; Clamp to the Bottom row
    JBE Bottom_Y_OK
    MOV AL, 24

Bottom_Y_OK:
    MOV DH, AL                  ; Set Y to the Bottom box

    INC DL
    MOV AL, CL                  ; Get Width
    DEC AL                      ; Length = Width -1
    JZ Skip_Btm_H
    
    MOV AH, AL
    MOV AL, [SI+4]              ; Select the horizontal char
    CALL Vid_Txt_Draw_HLine

Skip_BTM_H:
    POP DX
    ; --- END OF PHASE 2 ---

    ; --- PHASE 3: VERTICAL WALLS ---
    ; --- DRAW LEFT PILLAR ---
    PUSH DX                     ; Save original X,Y
    INC DH                      ; Start 1 row BELOW TL Corner
    MOV AL, CH                  ; Get Height
    SUB AL, 1                   ; Trim Height by 1 so it doesn't overwrite the BL Corner
    JZ Skip_Left_V              ; If Height was 1, no gap to fill (doesn't really get called due to the clamping)

    MOV CH, AL                  ; Pillar Height
    MOV AL, [SI+5]              ; Get vertical char
    CALL Vid_Txt_Draw_VLine     ; Draw the left pillar

Skip_Left_V:
    POP DX

    ; --- DRAW RIGHT PILLAR ---
    PUSH DX                     ; Save original X,Y
    ; Calculate Right X (same logic as TR Corner)
    INC DL
    MOV AL, DL
    ADD AL, CL
    CMP AL, 79                  ; Clamp to the right edge
    JBE Right_X_OK
    MOV AL, 79

Right_X_OK:
    MOV DL, AL                  ; Mov X to the right side of box

    INC DH                      ; Start 1 row BELOW TR corner
    MOV AL, CH                  ; Get Height
    DEC AL                      ; Length = Height - 1

    JZ Skip_Right_V

    MOV AH, AL                  ; Pillar Length
    MOV AL, [SI+5]              ; Vertical Sytle character
    CALL Vid_Txt_Draw_VLine     ; Draw the right pillar

Skip_Right_V:
    POP DX
    ; --- END OF PHASE 3 ---
Border_Exit:
    ; --- CLEAN UP PHASE ---

    POP AX
    POP CX
    POP DX
    RET
Vid_Txt_Draw_Border ENDP


; --- VID_TXT_DRAW_PANEL ---
; DL=X, DH=Y, CL=W, CH=H BL=Attr, BH=Style
; Style: 0=None, 1=Single, 2=Double
Vid_Txt_Draw_Panel PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI


    ; 1. Draw the Background (The "Floor")

    PUSH DX                     ; Save original X/Y
    PUSH CX                     ; Save original Width/Height
    MOV AL, ' '                 ; Fill with Space
    CALL Vid_Txt_Draw_Box
    POP CX                      ; Restore W/H for the border logic
    POP DX                      ; Restore X/Y for the border logic
    
    ; 2. Check Style for Borders
    CMP BH, 0                   ; Style 0 = Borderless Panel 
    ;-------------------------NOTE-----------------------
    ; Don't need explict BH 1 comparison because it will;
    ; fall through to it if not 0 or 2                  ;
    ; CMP BH, 1                                         ;
    ; JE Style_1             ; Single Border            ;
    ;----------------------------------------------------
    CMP BH, 2
    JE Style_2             ; Double Border

Style_1:
    ; Use Single Line Chars (0DAH, 0BFH, 0C0H, 0D9H, 0C4H, 0B3H)
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