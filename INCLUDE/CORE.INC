; INCLUDE\CORE.INC
; ---  Salix 16 Core Module ---
;  -- HW Detection           --
EXTRN Get_CPU_Type
;  --
;  -- Memory Gap Management  --
EXTRN Gap_Init:PROC
EXTRN Gap_Move_Left:PROC
EXTRN Gap_Move_Right:PROC
EXTRN Gap_Move_Up:PROC
EXTRN Gap_Move_Down:PROC
EXTRN Gap_Insert_Char:PROC
EXTRN Find_Line_Start:PROC
;  --                        --
;------------------------------