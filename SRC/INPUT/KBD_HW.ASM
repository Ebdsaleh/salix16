; SRC\INPUT\KBD_HW.ASM
; --- Salix16 KEYBOARD DIRECT-TO-HARDWARE MODULE ---
TITLE SALIX_KBD_HW

.MODEL SMALL

INCLUDE DEFS.INC

.DATA
    ; --- The "Vault" for the original BIOS pointers ---
    PUBLIC Old_Int09_Offset
    Old_Int09_Offset    DW 0    ; To store the BIOS address
    PUBLIC Old_Int09_Segment
    Old_Int09_Segment   DW 0    ; So we can restore is later

    ; --- The "DNA" of the current keypress
    PUBLIC Salix_Raw_ScanCode
    Salix_Raw_ScanCode  DB 0    ; This is our "DNA" storage for the last key

.CODE
.386                            ; Allow 32-bit registers for speed
; Use 16-bit registers (AX instead of EAX) for total TASM 1.0 safety
PUBLIC Kbd_ISR_Install
PUBLIC Kbd_ISR_Remove

; --- THE ACTUAL INTERRUPT HANDLER ---
; ----------------------------------------------------------------
; New_Int09: The "Nervous System"
; ----------------------------------------------------------------
; This runs every time a key is pressed or released

New_Int09 PROC
    PUSH AX                     ; SAVE THE MACHINE STATE

    ; 1. Grab the raw scancode form the keyboard controller
    IN AL, 60H                  ; Read the Hardware Port
    MOV Salix_Raw_ScanCode, AL

    ; 2. Manual Acknowledge
    ; We must tell the keyboard controller we got the key
    IN AL, 61H                  ; Read Control Port
    OR AL, 80H                  ; Set the "Reset" bit High
    OUT 61H, AL                 ; Send it back
    AND AL, 7FH                 ; Clear the "Reset" bit (set-back to LOW)
    OUT 61H, AL                 ; Send it back to the resume normal ops

    ; 3. End of Interrupt (EOI) for the PIC
    MOV AL, 20H
    OUT 20H, AL
    
    POP AX
    IRET
New_Int09 ENDP

; --- INSTALL THE HANDLER ---
Kbd_ISR_Install PROC
    ; This part requires saving the OLD interrupt address
    ; to avoid an "Uh-Oh" when the program ends.
    ; We will implement the Vector Swap in the next pass.

    PUSH AX
    PUSH BX
    PUSH ES

    ; 1. Get and Save the Old Vector INT 09H vector
    MOV AX, 3509H
    INT 21H
    MOV Old_Int09_Offset, BX    ; Save Offset
    MOV Old_Int09_Segment, Es   ; Save Segment

    ; 2. Set our New_int09 handler as the primary
    PUSH DS
    
    MOV AX, SEG New_Int09
    MOV DS, AX                  ; DS:DX points to our new routine
    MOV DX, OFFSET New_Int09
    MOV AX, 2509H
    INT 21H
    POP DS

    POP ES
    POP BX
    POP AX
    RET
Kbd_ISR_Install ENDP    

; ----------------------------------------------------------------
; Kbd_ISR_Remove: The "Safety Gear" - Must be called on exit!
; ----------------------------------------------------------------
; Restores the original BIOS handler
Kbd_ISR_Remove PROC
    ; This Restores the BIOS to its original throne (hand control back to the BIOS)
    PUSH AX
    PUSH DX
    PUSH DS

    ; Restore the original BIOS pointer
    MOV DX, Old_Int09_Offset
    MOV AX, Old_Int09_Segment
    MOV DS, AX
    MOV AX, 2509H
    INT 21H

    POP DS
    POP DX
    POP AX
    RET

Kbd_ISR_Remove ENDP

END