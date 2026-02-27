; SRC\TEST.ASM
TITLE SALIX_TEST

.MODEL SMALL

INCLUDE DEFS.INC

; Tell TASM these are in the library
EXTRN Vid_Txt_Set_Mode:PROC
EXTRN Vid_Txt_Write_Char
EXTRN Kbd_ISR_Install:PROC
EXTRN Kbd_ISR_Remove:PROC

; Declare the variables we want to look at
.DATA
    EXTRN Salix_Raw_ScanCode:BYTE

.CODE
Main:
    ; 1. Setup the Environment
    CALL Vid_Txt_Set_Mode
    CALL Kbd_ISR_Install        ; IGNITE THE KEYBOARD

    ; 2. The "Pulse" Loop
    ; We will wait until the scancode changes from 0

    ; --- THE "SURGICAL" WIPE ---
    MOV Salix_Raw_ScanCode, 0   ; Wipe the "Enter" key ghost from the program
    ; ---------------------------

WaitForKey:
    CMP Salix_Raw_ScanCode, 0
    JE WaitForKey               ; Loop if no keypress has been detected

    ; 3.Visual Feedback
    ; Draw a Red '!' at 40, 12 to show we caught a hardware key
    MOV DL, 40                  ; X
    MOV DH, 12                  ; Y
    MOV AL, '!'                 ; Character
    MOV BL, 04H                 ; Red
    CALL Vid_Txt_Write_Char

    ; 4. Safety First - RESTORE THE BIOS
    CALL Kbd_ISR_Remove

    MOV AX, 4C00H               ; Return to DOS
    INT 21H

END Main