; INCLUDE\TUI_STRC.INC
; --- TUI_STRC.INC ---
; Salix16 TUI_STRC Text User Interface Structures / Structs

Tui_Menu_Slot STRUC
    MS_Title_Ptr        DW ?    ; Pointer to the string (File, Edit, etc.)
    MS_HotKey           DB ?    ; The ASCII trigger ('F', 'E')
    MS_X_Coord          DB ?    ; Screen column position (X)
    MS_Width            DB ?    ; How many characters wide it is.
Tui_Menu_Slot ENDS

; The Master Controller Menubar
Tui_Menu_Bar STRUC
    MB_SlotCount        DB ?    ; Number of slots (File, Edit, Search = 3)
    MB_ActiveIdx        DB ?    ; Which index is Highlighted (0, 1, 2...)
    MB_ColorNorm        DB ?    ; Default color (70H - Black on Grey)
    MB_ColorHigh        DB ?    ; Active color (OFH - White on Black)
    MB_SlotTable        DW ?    ; Pointer to an array of the Tui_Menu_Slot offsets
Tui_Menu_Bar ENDS