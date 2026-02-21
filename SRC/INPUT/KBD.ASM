; SRC\INPUT\KBD.ASM
; --- Salix16 KEYBOARD BIOS-COMMUNICATED MODULE ---
TITLE SALIX_KBD
INCLUDE DEFS.INC

.MODEL SMALL
.STACK 100H

.CODE
PUBLIC Kbd_Get_ScanCode

; Returns Scancode in AL(0 if no key pressed)
; Uses BIOS INT 16H. function 01H (Check Buffer)
Kbd_Get_ScanCode PROC
    MOV AH, 01H                 ; BIOS: Check for keystroke
    INT 16H                     ; Call Keyboard BIOS
    JZ No_Key                   ; Jump if Zero Flag set (No key in buffer)

    MOV AH, 00H                 ; BIOS: Get Keystroke from buffer
    INT 16H                     ; This clear the key from the BIOS "wait" list

    ; AL now contains the ASCII char
    ; AH now contains the Hardware Scancode
    ; For Vim-Motions (Arrows, Home, End), AH is more reliable

    MOV AL, AH                  ; We want the Scancode in AL for the API
    RET

No_Key:
    XOR AL, AL                  ; Return 0 if nothing is pressed
Kbd_Get_ScanCode ENDP

END