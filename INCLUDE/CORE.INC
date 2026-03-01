; INCLUDE\CORE.INC
; ---  Salix 16 Core Module ---
;  -- HW Detection           --
EXTRN Get_CPU_Type
;  --
;  -- Memory Gap Management  --
EXTRN Gap_Init:NEAR
EXTRN Gap_Move_Left:NEAR
EXTRN Gap_Move_Right:NEAR
EXTRN Gap_Move_Up:NEAR
EXTRN Gap_Move_Down:NEAR
EXTRN Gap_Insert_Char:NEAR
EXTRN Find_Line_Start:NEAR
;  --                        --
;------------------------------