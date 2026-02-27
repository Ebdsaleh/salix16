; SRC\CORE\DETECT.ASM
; --- Salix16 DETECT Module ---

TITLE SALIX_DETECT

.MODEL SMALL

INCLUDE DEFS.INC

.CODE
PUBLIC Get_CPU_Type

; Returns CPU Type in AX (Matching the DEFS.INC Constants)
Get_CPU_Type PROC
    PUSHF                       ; Save flags

    ; 1. Check for 8086 (Bits 12-15 are always 1)
    XOR AX, AX
    PUSH AX
    POPF                        ; Try to clear bits 12 - 15
    PUSHF
    POP AX
    AND AX, 0F000H
    CMP AX, 0F000H
    JE Is_8086

    ; 2. Check for 286 (Bits 12-15 are always 0 in real mode)
    MOV AX, 0F000H
    PUSH AX
    POPF                        ; Try to set bits 12-15
    PUSHF
    POP AX
    AND AX, 0F000H
    JZ Is_286

    ; 3. If it's not 8086 or 286 it's 386+
    ; (For Tier 1, we'll treat all 386/486/Pentium as '386', for now).
    MOV AX, CPU_386
    JMP Done

Is_8086:
    MOV AX, CPU_8086
    JMP Done

Is_286:
    MOV AX, CPU_286

Done:
    POPF                        ; Restore original flags
    RET
Get_CPU_Type ENDP

END
