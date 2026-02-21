@ECHO OFF
ECHO Building Salix16 Test Application...

REM Check if the library actually exists first
IF NOT EXIST BIN\SALIX16.LIB ECHO ERROR: BIN\SALIX16.LIB is missing! Run BUILDLIB.BAT first
IF NOT EXIST BIN\SALIX16.LIB GOTO END

REM --- Assemble the Test app ---
TASM /iINCLUDE SRC\TEST.ASM, BUILD\TEST.OBJ

REM --- Linnk against the Library ---
REM We add the semicolon at teh end of TLINK  to tel it "no more files".
REM Syntax: TLINK [ObjFile], [ExeFile], [MapFile], [LibFiles]
TLINK BUILD\TEST.OBJ, BIN\TEST.EXE, , BIN\SALIX16.LIB;

:END
IF EXIST BIN\TEST.EXE ECHO Build Success: Run BIN\TEST.EXE