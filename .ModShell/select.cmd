@ECHO OFF
CD /D !MODSHELL_HOME!
IF /I "%~1"=="none" (
    :: special case for deselect
    CALL deselect
    GOTO :EOF
)
ECHO.
:: show usage if no parameter
IF "%~1"=="" (
    CALL cmds select
    GOTO :EOF
)
:: show error if invalid parameter
IF NOT EXIST "%~1\build.gradle" (
    IF EXIST "%~1" (
        ꞈBG PRINT C "[X] " F "%~1" 7 " is not a valid Forge mod project. \n"
    ) ELSE (
        ꞈBG PRINT C "[X] " F "%~1" 7 " does not exist. \n"
        ꞈBG PRINT A "[i] " 7 "To create a new mod with this name, type: \n"
        ꞈBG PRINT F "create %~1" \n"
        echo.
    )
    GOTO :EOF
)
:: try to select mod
ꞈBG PRINT A "[i] " F "%~1" 7 " selected as current project \n"
CALL func modCheck %1
SET current_project=%~1
PROMPT $C Current$SProject:$S!current_project! $F$_$C$P$F$_$G$S
