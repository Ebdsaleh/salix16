; INCLUDE\KEYS.INC
; --- KEYS.INC ---
; --- KEYBOARD SCANCODE VALUES ---
; --- NOTE: FOR 101 Key- Keyboards, 386, 486 systems and up. 
; --- TOP ROW ---
KEYS_ESC        EQU 01H
KEY_F1          EQU 3BH
KEY_F2          EQU 3CH
KEY_F3          EQU 3DH
KEY_F4          EQU 3EH
KEY_F5          EQU 3FH
KEY_F6          EQU 40H
KEY_F7          EQU 41H
KEY_F8          EQU 42H
KEY_F9          EQU 43H
KEY_F10         EQU 44H
KEY_F11         EQU 57H     ; F11 was added later at 57h
KEY_F12         EQU 58H     ; F12 was added later at 58h
; --- NUMBERS ---
KEY_1           EQU 02H
KEY_2           EQU 03H
KEY_3           EQU 04H
KEY_4           EQU 05H
KEY_5           EQU 06H
KEY_6           EQU 07H
KEY_7           EQU 08H
KEY_8           EQU 09H
KEY_9           EQU 0AH
KEY_0           EQU 0BH

; --- NUMERIC KEYPAD ---
KPAD_SLASH      EQU 35H     ; Note: This is usually an 'E0' extended code
KPAD_STAR       EQU 37H
KPAD_MINUS      EQU 4AH
KPAD_PLUS       EQU 4EH
KPAD_ENTER      EQU 1CH     ; Note: Also usually an 'E0' extended code
KPAD_PERIOD     EQU 53H     ; Del (when NumLock is off)

KPAD_0          EQU 52H     ; Ins
KPAD_1          EQU 4FH     ; End
KPAD_2          EQU 50H     ; Down Arrow
KPAD_3          EQU 51H     ; PgDn
KPAD_4          EQU 4BH     ; Left Arrow
KPAD_5          EQU 4CH     ; Center (5)
KPAD_6          EQU 4DH     ; Right Arrow
KPAD_7          EQU 47H     ; Home
KPAD_8          EQU 48H     ; Up Arrow
KPAD_9          EQU 49H     ; PgUp

; --- DEDICATED NAVIGATION (Non-Numpad) ---
KEY_INSERT      EQU 52H
KEY_DELETE      EQU 53H
KEY_HOME        EQU 47H
KEY_END         EQU 4FH
KEY_PGUP        EQU 49H
KEY_PGDN        EQU 51H
KEY_UP          EQU 48H
KEY_LEFT        EQU 4BH
KEY_DOWN        EQU 50H
KEY_RIGHT       EQU 4DH

; --- LETTERS ---
; --- QWERTY TOP ROW ---
KEY_TAB         EQU 0FH
KEY_Q           EQU 10H
KEY_W           EQU 11H
KEY_E           EQU 12H
KEY_R           EQU 13H
KEY_T           EQU 14H
KEY_Y           EQU 15H
KEY_U           EQU 16H
KEY_I           EQU 17H
KEY_O           EQU 18H
KEY_P           EQU 19H
KEY_L_BRACKET   EQU 1AH
KEY_R_BRACKET   EQU 1BH
KEY_ENTER       EQU 1CH
KEY_RETURN      EQU 1CH

; --- ASDF HOME ROW ---
KEY_L_CTRL      EQU 1DH
KEY_A           EQU 1EH
KEY_S           EQU 1FH
KEY_D           EQU 20H
KEY_F           EQU 21H
KEY_G           EQU 22H
KEY_H           EQU 23H
KEY_J           EQU 24H
KEY_K           EQU 25H
KEY_L           EQU 26H
KEY_SEMICOLON   EQU 27H
KEY_QUOTE       EQU 28H
KEY_TILDE       EQU 29H

; --- ZXCV BOTTOM ROW ---
KEY_L_SHIFT     EQU 2AH
KEY_BACKSLASH   EQU 2BH
KEY_Z           EQU 2CH
KEY_X           EQU 2DH
KEY_C           EQU 2EH
KEY_V           EQU 2FH
KEY_B           EQU 30H
KEY_N           EQU 31H
KEY_M           EQU 32H
KEY_COMMA       EQU 33H
KEY_PERIOD      EQU 34H
KEY_SLASH       EQU 35H
KEY_R_SHIFT     EQU 36H
KEY_SPACE       EQU 39H

; --- MODIFIER & STATUS KEYS ---
KEY_CAPSLOCK    EQU 3AH
KEY_NUMLOCK     EQU 45H
KEY_SCROLL      EQU 46H

KEY_L_ALT       EQU 38H
KEY_R_ALT       EQU 38H     ; Often sends E0 38
KEY_R_CTRL      EQU 1DH     ; Often sends E0 1D

; --- MODERN / EXTENDED KEYS ---
KEY_L_WIN       EQU 5BH     ; Left Super/Windows
KEY_R_WIN       EQU 5CH     ; Right Super/Windows
KEY_MENU        EQU 5DH     ; Context Menu key