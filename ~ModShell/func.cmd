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
SET folderBrowseResult=!STRIP_PATH_RESULT!
SET STRIP_PATH_RESULT=
GOTO :EOF

:trimToFinalElement
:: Removes the leading path, getting only the final directory/file name
FOR %%F IN ("%~2") DO SET trimToFinalElementResult=%%~nxF
GOTO :EOF


:::::::::::::::::::
:: USED INTERNALLY
:::::::::::::::::::
:STRIP_PATH
:: Strips trailing slashes from a directory path, and also a filename is found
IF NOT EXIST "%~1\*" (
    :: Not a directory; strip filename from path
    SET STRIP_PATH_RESULT=%~dp1
)
:: Strip trailing slash if found
IF %STRIP_PATH_RESULT:~-1%==\ SET STRIP_PATH_RESULT=%STRIP_PATH_RESULT:~0,-1%
GOTO :EOF
