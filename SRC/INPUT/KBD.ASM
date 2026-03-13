; SRC\INPUT\KBD.ASM
; --- Salix16 KEYBOARD BIOS-COMMUNICATED MODULE ---
TITLE SALIX_KBD

.MODEL SMALL

INCLUDE DEFS.INC

.DATA
Kbd_Map LABEL BYTE
    ; Row 00h - 07h
    DB 0, 0         ; 00h - Null
    DB 27, 27       ; 01h - KEY_ESC (ASCII 27)
    DB '1', '!'     ; 02h - KEY_1
    DB '2', '@'     ; 03h - KEY_2
    DB '3', '#'     ; 04h - KEY_3
    DB '4', '$'     ; 05h - KEY_4
    DB '5', '%'     ; 06h - KEY_5
    DB '6', '^'     ; 07h - KEY_6
    
    ; Row 08h - 0Fh
    DB '7', '&'     ; 08h - KEY_7
    DB '8', '*'     ; 09h - KEY_8
    DB '9', '('     ; 0Ah - KEY_9
    DB '0', ')'     ; 0Bh - KEY_0
    DB '-', '_'     ; 0Ch - KEY_MINUS
    DB '=', '+'     ; 0Dh - KEY_EQUAL
    DB 8, 8         ; 0Eh - KEY_BACKSPACE (ASCII 8)
    DB 9, 9         ; 0Fh - KEY_TAB (ASCII 9)
    
    ; Row 10h - 17h (Top Letter Row)
    DB 'q', 'Q'     ; 10h - KEY_Q
    DB 'w', 'W'     ; 11h - KEY_W
    DB 'e', 'E'     ; 12h - KEY_E
    DB 'r', 'R'     ; 13h - KEY_R
    DB 't', 'T'     ; 14h - KEY_T
    DB 'y', 'Y'     ; 15h - KEY_Y
    DB 'u', 'U'     ; 16h - KEY_U
    DB 'i', 'I'     ; 17h - KEY_I

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