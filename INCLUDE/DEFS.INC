; INCLUDE\DEFS.INC
; --- Salix 16 Master Architecture Definitions
; -------------------------------------------- 

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