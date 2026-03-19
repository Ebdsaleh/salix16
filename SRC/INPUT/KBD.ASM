; SRC\INPUT\KBD.ASM
; --- Salix16 KEYBOARD BIOS-COMMUNICATED MODULE ---
TITLE SALIX_KBD

.MODEL SMALL

INCLUDE DEFS.INC

.DATA
; ===========================================================================
; Kbd_Map - The ASCII Character Dictionary
; ---------------------------------------------------------------------------
; PURPOSE: Maps raw hardware scancode strictly to printable ASCII characters.
;          Only "ink on paper" keys get values here.
;
; WARNING: Navigation (Arrows), (Modifiers (Shift/Ctrl), and Toggles (CAPS)
;          MUST be mapped to 0, 0. The API Logic handles their state
;          separately inside the Key_Signal manifest.
; ===========================================================================

Kbd_Map LABEL BYTE
    ; Row 00H - 07H
    DB 0, 0         ; 00H - Null
    DB 27, 27       ; 01H - KEY_ESC (ASCII 27)
    DB '1', '!'     ; 02H - KEY_1
    DB '2', '@'     ; 03H - KEY_2
    DB '3', '#'     ; 04H - KEY_3
    DB '4', '$'     ; 05H - KEY_4
    DB '5', '%'     ; 06H - KEY_5
    DB '6', '^'     ; 07H - KEY_6
    
    ; Row 08H - 0FH
    DB '7', '&'     ; 08H - KEY_7
    DB '8', '*'     ; 09H - KEY_8
    DB '9', '('     ; 0AH - KEY_9
    DB '0', ')'     ; 0BH - KEY_0
    DB '-', '_'     ; 0CH - KEY_MINUS
    DB '=', '+'     ; 0DH - KEY_EQUAL
    DB 8, 8         ; 0EH - KEY_BACKSPACE (ASCII 8)
    DB 9, 9         ; 0FH - KEY_TAB (ASCII 9)
    
    ; Row 10H - 17H 
    DB 'q', 'Q'     ; 10H - KEY_Q
    DB 'w', 'W'     ; 11H - KEY_W
    DB 'e', 'E'     ; 12H - KEY_E
    DB 'r', 'R'     ; 13H - KEY_R
    DB 't', 'T'     ; 14H - KEY_T
    DB 'y', 'Y'     ; 15H - KEY_Y
    DB 'u', 'U'     ; 16H - KEY_U
    DB 'i', 'I'     ; 17H - KEY_I

    ; Row 18H - 1FH 
    DB 'o', 'O'     ; 18H - KEY_O
    DB 'p', 'P'     ; 19H - KEY_P
    DB '[', '{'     ; 1AH - KEY_L_BRACKET
    DB ']', '}'     ; 1BH - KEY_R_BRACKET
    DB 13, 13       ; 1CH - KEY_ENTER (ASCII 13 Carriage return)
    DB 0, 0         ; 1DH - KEY_L_CTRL (ASCII 29)
    DB 'a', 'A'     ; 1EH - KEY_A
    DB 's', 'S'     ; 1FH - KEY_S

    ; Row 20H - 27H
    DB 'd', 'D'     ; 20H - KEY_D
    DB 'f', 'F'     ; 21H - KEY_F
    DB 'g', 'G'     ; 22H - KEY_G
    DB 'h', 'H'     ; 23H - KEY_H
    DB 'j', 'J'     ; 24H - KEY_J
    DB 'k', 'K'     ; 25H - KEY_K
    DB 'l', 'L'     ; 26H - KEY_L
    DB ';', ':'     ; 27H - KEY_SEMICOLON

    ; Row 28H - 2FH
    DB "'", '"'     ; 28H - KEY_QUOTE
    DB '`', '~'     ; 29H - KEY_TILDE
    DB 0, 0         ; 2AH - KEY_L_SHIFT (ASCIII 42)
    DB '\', '|'     ; 2BH - KEY_BACKSLASH (ASCII 43)
    DB 'z', 'Z'     ; 2CH - KEY_Z
    DB 'x', 'X'     ; 2DH - KEY_X
    DB 'c', 'C'     ; 2EH - KEY_C
    DB 'v', 'V'     ; 2FH - KEY_V

    ; Row 30H - 37H
    DB 'b', 'B'     ; 30H - KEY_B
    DB 'n', 'N'     ; 31H - KEY_N
    DB 'm', 'M'     ; 32H - KEY_M
    DB ',', '<'     ; 33H - KEY_COMMA
    DB '.', '>'     ; 34H - KEY_PERIOD
    DB '/', '?'     ; 35H - KEY_SLASH
    DB 0, 0         ; 36H - KEY_R_SHIFT
    DB '*', '*'     ; 37H - KEY_START

    ; Row 38H - 3FH
    DB 0, 0         ; 38H - KEY_L_ALT (ASCII 54)
    DB ' ', ' '     ; 39H - KEY_SPACE
    DB 0, 0         ; 3AH - KEY_CAPSLOCK (ASCII 58)
    DB 0, 0         ; 3BH - KEY_F1 (ASCII 59)
    DB 0, 0         ; 3CH - KEY_F2 (ASCII 60)
    DB 0, 0         ; 3DH - KEY_F3 (ASCII 61)
    DB 0, 0         ; 3EH - KEY_F4 (ASCII 62)
    DB 0, 0         ; 3FH - KEY_F5 (ASCII 63)

    ; Row 40H - 47H
    DB 0, 0         ; 40H - KEY_F6 (ASCII 64)
    DB 0, 0         ; 41H - KEY_F7 (ASCII 65)
    DB 0, 0         ; 42H - KEY_F8 (ASCII 66)
    DB 0, 0         ; 43H - KEY_F9 (ASCII 67)
    DB 0, 0         ; 44H - KEY_F10 (ASCII 68)
    DB 0, 0         ; 45H - KEY_NUMLOCK(ASCII 69)
    DB 0, 0         ; 46H - KEY_SCROLL (ASCII 70)
    DB '7', 0       ; 47H - KPAD_7 / KEY_HOME (ASCII 71) 

    ; Row 48H - 4FH
    DB '8', 0       ; 48H - KPAD_8 / KEY_UP (ASCII 72)
    DB '9', 0       ; 49H - KPAD_9 / KEY_PGUP (ASCII 73)
    DB '-', '-'     ; 4AH - KPAD_MINUS (ASCII 74)
    DB '4', 0       ; 4BH - KPAD_4 / KEY_LEFT (ASCII 75)
    DB '5', '5'     ; 4CH - KPAD_5 (ASCII 76)
    DB '6', 0       ; 4DH - KPAD_6 / KEY_RIGHT (ASCII 77)
    DB '+', '+'     ; 4EH - KEY_PLUS (ASCII 78)
    DB '1', 0       ; 4FH - KPAD_1 / KEY_END (ASCII 79) 

    ; Row 50H - 57H
    DB '2', 0       ; 50H - KPAD_2 / KEY_DOWN
    DB '3', 0       ; 51H - KPAD_3 / KEY_PGDN
    DB '0', 0       ; 52H - KPAD_0 / KEY_INSERT
    DB '.', 0       ; 53H - KPAD_PERIOD / KEY_DELETE
    DB 0, 0         ; 54H - KEY_PRINT
    DB 0, 0         ; 55H - Reserved
    DB 0, 0         ; 56H - Reserved
    DB 0, 0         ; 57H - KEY_F11

    ; Row 58H - 5FH
    DB 0, 0         ; 58H - KEY_F12
    DB 0, 0         ; 59H - Reserved
    DB 0, 0         ; 5AH - Reserved
    DB 0, 0         ; 5BH - KEY_L_WIN
    DB 0, 0         ; 5CH - KEY_R_WIN
    DB 0, 0         ; 5DH - KEY_MENU
    DB 0, 0         ; 5EH - KEY_POWER      
    DB 0, 0         ; 5FH - KEY_SLEEP

    ; Row 60H - 67H
    DB 0, 0         ; 60H - Reserved
    DB 0, 0         ; 61H - Reserved
    DB 0, 0         ; 62H - Reserved
    DB 0, 0         ; 63H - Reserved
    DB 0, 0         ; 64H - KEY_F13 (Rare / Laptop)
    DB 0, 0         ; 65H - KEY_F14 (Rare / Laptop)
    DB 0, 0         ; 66H - KEY_F15 (Rare / Laptop)
    DB 0, 0         ; 67H - Reserved

    ; Row 68H - 6FH
    DB 0, 0         ; 68H - Reserved
    DB 0, 0         ; 69H - Reserved
    DB 0, 0         ; 6AH - Reserved
    DB 0, 0         ; 6BH - Reserved
    DB 0, 0         ; 6CH - Reserved
    DB 0, 0         ; 6DH - KEY_ERASE_EOF (Legacy Mainframe Termial key)
    DB 0, 0         ; 6EH - Reserved
    DB 0, 0         ; 6FH - Reserved

    ; Row 70H - 77H
    DB 0, 0         ; 70H - Reserved
    DB 0, 0         ; 71H - Reserved
    DB 0, 0         ; 72H - Reserved
    DB 0, 0         ; 73H - Reserved
    DB 0, 0         ; 74H - Reserved
    DB 0, 0         ; 75H - Reserved
    DB 0, 0         ; 76H - Reserved
    DB 0, 0         ; 77H - Reserved

    ; Row 78H -7FH
    DB 0, 0         ; 78H - Reserved
    DB 0, 0         ; 79H - Reserved
    DB 0, 0         ; 7AH - Reserved
    DB 0, 0         ; 7BH - Reserved
    DB 0, 0         ; 7CH - Reserved
    DB 0, 0         ; 7DH - Reserved
    DB 0, 0         ; 7EH - Reserved
    DB 0, 0         ; 7FH - Reserved

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