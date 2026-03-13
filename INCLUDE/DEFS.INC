; INCLUDE\DEFS.INC
; --- Salix 16 Master Architecture Definitions
; -------------------------------------------- 

INCLUDE KEYS.INC

; CPU Types
CPU_8086        EQU 0
CPU_286         EQU 1
CPU_386         EQU 2
CPU_486         EQU 3
CPU_PENTIUM     EQU 4


; Video Modes
MODE_TEXT       EQU 03H ; Standard 80x25 Text Console mode
MODE_VGA        EQU 13H ; 320x200 256-Color mode

; API Handshake - Carry Flag (CF)
; Clear  (0)  = Success
; Set    (1)  = Failure (Error code in AX)

; Aliases (Macros)
; This Maps 'clean' names to the 'Gritty' source names
CLS             EQU <CALL Vid_Txt_Clear_Screen>
SetMode         EQU <CALL Vid_Txt_Set_Mode>
PutChar         EQU <CALL Vid_Txt_Write_Char>
GetKey          EQU <CALL Kbd_Get_Key>
GetKeyCode      EQU <CALL Kbd_Get_ScanCode>


; Color palette
BLACK           EQU 0
DARK_BLUE       EQU 1
DARK_GREEN      EQU 2
DARK_CYAN       EQU 3
DARK_RED        EQU 4
DARK_MAGENTA    EQU 5
BROWN           EQU 6
LIGHT_GRAY      EQU 7
DARK_GRAY       EQU 8
BLUE            EQU 9
GREEN           EQU 10
CYAN            EQU 11
RED             EQU 12
MAGENTA         EQU 13
YELLOW          EQU 14
WHITE           EQU 15


; --- Salix16 Constants ---
KEY_STATE_UP    EQU 0
KEY_STATE_DOWN  EQU 1

; --- Salix16 Keyboard Signal Spec ---
KeySignal STRUC
    ; The Manifest: Allows 16-bit PUSH/POP or MOV of the first two fields
    Manifest    DB 6 DUP(0) ; 6 bytes, holds all attributes, useful for validation and storing.
    ; We use ORG to "reset" the pointer to the start of the manifest
    ORG 0       

    ; Individual Attributes
    Scan_code   DB 0        ; Physical ID (Offset 0 in Manifest)
    State       DB 0        ; Press/Release (Offset 1 in Manifest)
    Char_Lo     DB 0        ; Normal ASCII
    Char_Hi     DB 0        ; Shifted ASCII
    Is_Modifier DB 0        ; 1 = Modifier, 0 = Content
    Padding     DB 0        ; Pads to 6 bytes (3 Words) for CPU alignment
KeySignal ENDS