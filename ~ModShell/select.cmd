@ECHO OFF
ECHO.
IF EXIST "%~1\build.gradle" (
    BG PRINT A "[i] " F "%~1" 7 " selected as current project \n"
    SET _modDir=%~1
    SET _modDirNoSpace=!_modDir: =!
    IF NOT !_modDir!==!_modDirNoSpace! (
        BG PRINT E "    [^!] " 7 "Mod project has a space in it's directory. This will *VERY* likely cause problems^! \n"
    )
    SET _modDir=
    SET _modDirNoSpace=
    SET current_project=%~1
    PROMPT $C Current$SProject:$S!current_project! $F$_$C$P$F$_$G$S
) ELSE (
    BG PRINT C "[X] " F "%~1" 7 " is not a valid Forge mod project. \n"
)