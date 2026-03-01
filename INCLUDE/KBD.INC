; INCLUDE\KBD.INC
; --- Salix16 KeyBoard Module ---
EXTRN Kbd_ISR_Install:NEAR
EXTRN Kbd_ISR_Remove:NEAR
EXTRN Kbd_Get_Key:NEAR
EXTRN Kbd_Get_ScanCode:NEAR
EXTRN Kbd_Await_Keystroke

; --- Data Exports ---
EXTRN Salix_Raw_ScanCode:BYTE
