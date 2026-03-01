; SRC\CORE\MEM_GAP.ASM
; --- Salix16 Memory Gap Module ---
TITLE SALIX_MEM_GAP

.MODEL SMALL

INCLUDE DEFS.INC

.DATA
    ; 1. The Physical Storage (16,384 bytes of zeros)
    ; This is the "Warehouse" for the text.
    Raw_Buffer  DB  16384 DUP(0)

    ; 2. These are the 4 Pillars (Pointers) of the Gap Buffer
    ; Declare
    PUBLIC Buf_Start
    Buf_Start    DW 0
    PUBLIC Gap_Start
    Gap_Start    DW 0
    PUBLIC Gap_End
    Gap_End      DW 0
    PUBLIC Buf_End
    Buf_End      DW 0

.CODE
PUBLIC Gap_Init
PUBLIC Gap_Move_Left
PUBLIC Gap_Move_Right
PUBLIC Gap_Move_Up
PUBLIC Gap_Move_Down
PUBLIC Gap_Insert_Char
PUBLIC Find_Line_Start

; Initializes a 16KB buffer for our editor
; Using a static block for simplicity in TASM 1.0
Gap_Init PROC NEAR
    ; Set Buf_Start to the beginning of our Raw_Buffer
    MOV AX, OFFSET Raw_Buffer
    MOV Buf_Start, AX
    ; Initially, the Gap starts at the begining
    MOV Gap_Start, AX

    ; Set Buf_End to the very end of the Raw_Buffer
    ADD AX, 16384
    MOV Buf_End, AX

    ; Initially, the Gap ends at the very end (Full empty buffer)
    MOV Gap_End, AX
    
    Ret
Gap_Init ENDP

; --- HELPER: Find Start of the Current Line ---
; Returns Offset in BX
Find_Line_Start PROC NEAR
    MOV BX, Gap_Start
    DEC BX                      ; Start look before the Gap

Line_Loop:
    CMP BX, Buf_Start
    JE  At_Start                ; Stop if we hit the very beginning

    ; Check the character at [BX]
    MOV AL, [BX]
    CMP AL, 0AH                 ; IS is a NewLine?
    JE  Found_Line

    DEC BX
    JMP Line_Loop

At_Start:
    MOV BX, Buf_Start

Found_Line:
    RET
Find_Line_Start ENDP

; Moves the cursor one character to the Left
Gap_Move_Left PROC NEAR
    PUSH AX
    PUSH SI
    PUSH DI

    ; 1. Can we move left (Is Gap_Start > Buf_Start)
    MOV AX, Gap_Start
    CMP AX, Buf_Start
    JE Move_Left_Done           ; At the very beginning, do nothing

    ; 2. The SlideL Move char from Left-of-Gap to Right-of-Gap
    ; SI = Source (Char just before Gap_Start)
    ; DI = Destination (The very last byte of the Gap)
    DEC AX
    MOV SI, AX

    MOV AX, Gap_End
    DEC AX                      ; AX = Gap_End - 1
    MOV DI, AX

    MOV AL, [SI]                ; Pick up the character
    MOV [DI], AL                ; Drop it on the other side of the "hole"

    ; 3. Update Pointers
    DEC Gap_Start
    DEC Gap_End

Move_Left_Done:
    POP DI
    POP SI
    POP AX
    RET
Gap_Move_Left ENDP

; Moves the cursor one character to the Right
Gap_Move_Right PROC NEAR
    PUSH AX
    PUSH SI
    PUSH DI

    ; 1. Can we move right? (Is Gap_end < Buf_End?)
    MOV AX, Gap_End
    CMP AX, Buf_End
    JE  Move_Right_Done         ; At the very end. do nothing

    ; This Slide: Move char from Right-of-Gap to Left-of-Gap
    MOV SI, Gap_End             ; Source
    MOV DI, Gap_Start           ; Destination

    MOV AL, [SI]                ; Pick up the character
    MOV [DI], AL                ; Drop it at the start of the "hole"

    ; 3. Update Pointers
    INC Gap_Start
    INC Gap_End
Move_Right_Done:
    POP DI
    POP SI
    POP AX
    RET
Gap_Move_Right ENDP

; --- GAP MOVE UP ---
Gap_Move_Up PROC NEAR
    CALL Find_Line_Start
    
    ; If BX == Buf_Start, we can't move up
    CMP BX, Buf_Start
    JE  Move_Up_Done
    
    ; More may be added later if required.

Move_Up_Done:
    RET
Gap_Move_Up ENDP

; --- GAP MOVE DOWN ---
Gap_Move_Down PROC NEAR
    MOV BX, Gap_End

Down_Loop:
    CMP BX, Buf_End
    JE  Move_Down_Done          ; Stop if we hit the end of the warehouse    

    MOV AL, [BX]                ; Look ahead past the gap
    CMP AL, 0AH                 ; Found a NewLine?
    JE  Found_Next_Line

    CALL Gap_Move_Right         ; Shift the gap forward
    MOV BX, Gap_End             ; Refresh pointer
    JMP Down_Loop

Found_Next_Line:
    CALL Gap_Move_Right         ; Move one more to sit at the start of the NEW Line

Move_Down_Done:
    RET
Gap_Move_Down ENDP

; The "Weld": Moves the Gap to a new position
; BX = Direction (1 = Left, 2 = Right, 3 = Up, 4 = Down)
; This is where  we shuffle memory if the user moves the cursor
; We'll write the "Block Move" logic next

Gap_Move_Cursor PROC NEAR
    CMP Bx, 1
    JE  Do_Move_Left
    
    CMP BX, 2
    JE  Do_Move_Right
    
    CMP BX, 3
    JE  Do_Move_Up
    
    CMP BX, 4
    JE  Do_Move_Down
    
    RET

Do_Move_Left:
    CALL Gap_Move_Left
    RET

Do_Move_Right:
    CALL Gap_Move_Right
    RET

Do_Move_Up:
    CALL Gap_Move_Up
    RET

Do_Move_Down:
    CALL Gap_Move_Down
    RET
Gap_Move_Cursor ENDP

; Inserts a character into the Gap
; AL = Character to insert
Gap_Insert_Char PROC NEAR
    PUSH BX
    PUSH DI

    ; 1. Check if the gap is empty (Gap_Start == Gap_End)
    MOV BX, Gap_Start
    CMP BX, Gap_End 
    JE  Buffer_Full             ; If they meet, the "Warehouse" is full

    ; 2. Place the char at the Start of the Gap
    MOV DI, BX                  ; DI = Gap_Start
    MOV [DI], AL                ; Write the character DNA

    ; 3. Move the Gap_Start forward
    INC BX
    MOV Gap_Start, BX

Buffer_Full:
    POP DI
    POP BX
    RET
Gap_Insert_Char ENDP

END