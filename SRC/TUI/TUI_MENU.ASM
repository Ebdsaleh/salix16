; SRC\TUI\TUI_MENU.ASM
; --- Salix16 TUI MENU MODULE --- TEXT USER INTERFACE
TITLE SALIX_TUI_MENU
INCLUDE DEFS.INC

.MODEL SMALL
.STACK 100H

PUBLIC Tui_Menu_Draw_Bar

.CODE
EXTRN Vid_Txt_Write_String

; ------------------------------------------------------
; Tui_Menu_Draw_Bar
; Input: SI = Offset of a MenuBar Structure
; ------------------------------------------------------
Tui_Menu_Draw_Bar PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    ; 1. Load Bar Metadata
    MOV CL, [SI].MB_SlotCount   ; Loop Counter
    XOR CH, CH                  ; Clear high byte for CX loop
    MOV DI, [SI].MB_SlotTable   ; DI points to our array of pointers
    MOV AL, [SI].MB_ActiveIdx   ; Whic one is currently active?

    XOR DX, DX                  ; DX will track our current slot index

Draw_Loop:
    PUSH SI                     ; Vault the MenuBar pointer

    ; 2. Get the pointer to the current Slot
    MOV SI, [DI]                ; SI now points to a Tui_Menu_Slot

    ; 3. Determine Color (Normal vs. Highlight)
    CMP AL, DL                  ; Is this the Active index?
    JE Set_Highlight

    ; Use Normal Color
    POP SI                      ; Get Bar back to read ColorNorm
    PUSH SI
    MOV BL, [SI].MB_ColorNorm
    JMP Do_Draw

Set_Highlight:
    ; Use Highlight Color
    POP SI                     ; Get Bar back to read ColorHigh
    PUSH SI
    MOV BL, [SI].MB_ColorHigh

Do_Draw:
    ; 4. Prepare for Vid_Txt_Write_String
    MOV DH, 0                   ; Menubar is always Row 0
    MOV DL, [SI].MS_X_Coord     ; Get X from the Slot
    MOV SI, [SI].MS_Title_Ptr   ; Get String Pointer from the slot
    CALL Vid_Txt_Write_String

    ; 5. Increment and Loop
    POP SI                      ; Restore MenuBar Pointer
    ADD DI, 2                   ; Move to next pointer in table (DW = 2 bytes)
    INC DL                      ; Increment our index counter
    LOOP Draw_Loop              ; Repeat until CX = 0 

    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
Tui_Menu_Draw_Bar ENDP

END