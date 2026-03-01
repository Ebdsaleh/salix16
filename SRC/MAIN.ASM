; SRC\MAIN.ASM
TITLE SALIX_MAIN
 
.MODEL SMALL
.STACK 100H

INCLUDE SALIX.INC

.DATA
EXTRN Salix_Raw_ScanCode:BYTE

.CODE
; External Routines (The "Handshake")
EXTRN Get_CPU_Type:PROC
EXTRN Vid_Txt_Set_Mode:PROC
EXTRN Vid_Txt_Clear_Screen:PROC
EXTRN Vid_Txt_Write_Char:PROC

Main PROC NEAR
    ; 1. Standard Startup
    MOV AX, @DATA
    MOV DS, AX

    ; 2. Ignite the Engine
    CALL Vid_Txt_Set_Mode       ; Clear and set text mode 80x25
    CALL Vid_Txt_Clear_Screen

    ; 3. The "DNA" Test - Print 'S' for Salix
    ; X=40 (Middle), Y=12 (Middle), Char='S', Color=0EH (Yellow)
    MOV DL, 40
    MOV DH, 12
    MOV AL, 'S'
    MOV BL, 0EH
    CALL Vid_Txt_Write_Char

    ; --- THE HEARTBEAT: Show the raw scancode in the Footer ---
    MOV DL, 75
    MOV DH, 24
    MOV AL, Salix_Raw_ScanCode
    ADD AL, 30H
    MOV BL, 30H
    CALL Vid_Txt_Write_Char

    ; --- EXIT CHECK ---
    CMP Salix_Raw_ScanCode, 01H ; Escape Key
    JNE Main

    ; 4. Graceful Exit to DOS
    MOV AX, 4C00H
    INT 21H
Main ENDP
END Main                       