@ECHO OFF
IF "%~1"=="" (
    echo.
    ꞈBG PRINT C "[X] " 7 "func is only useful for internal ModShell functions. \n"
    GOTO :EOF
)
SET _func=%1
CALL :!_func! %*
SET _func=
GOTO :EOF

:settings
IF "%~2" == "set" (
    ꞈInifile !SETTINGS! [%3] %4=!%4!
) ELSE (
    FOR /F "delims=" %%A IN ('ꞈInifile !SETTINGS! [%3] %4') DO %%A
)
GOTO :EOF

:folderBrowse
SET /P folderBrowseResult=%~2^> 
IF NOT EXIST !folderBrowseResult! (
    SET showGui=true
)
IF "!folderBrowseResult!"=="" (
    SET showGui=true
)
IF DEFINED showGui (
    SET showGui=
    FOR /F "delims=" %%A IN ('ꞈwfolder2 "set folderBrowseResult=" "C:\" "%~2 "') DO %%A
)
SET folderBrowseResult=!folderBrowseResult:"=!
CALL :STRIP_PATH !folderBrowseResult!
GOTO :EOF



:::::::::::::::::::
:: USED INTERNALLY
:::::::::::::::::::
:STRIP_PATH
IF NOT EXIST "%~1\*" (
    :: assume that a full file path was given, rather than just a directory path
    SET folderBrowseResult=%~dp1
)
:: Strip trailing slash if found
IF %folderBrowseResult:~-1%==\ SET folderBrowseResult=%folderBrowseResult:~0,-1%
GOTO :EOF
