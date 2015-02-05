@ECHO OFF
ECHO.
SET /P folderBrowseResult=%~1^> 
IF NOT EXIST !folderBrowseResult! (
    SET showGui=true
)
IF "!folderBrowseResult!"=="" (
    SET showGui=true
)
IF DEFINED showGui (
    SET showGui=
    FOR /F "delims=" %%A IN ('wfolder2 "set folderBrowseResult=" "C:\" "%~1 "') DO %%A
)
SET folderBrowseResult=!folderBrowseResult:"=!
CALL :STRIP_PATH !folderBrowseResult!
ECHO.
GOTO :EOF

:STRIP_PATH
IF NOT EXIST "%~1\*" (
    :: assume that a full file path was given, rather than just a directory path
    SET folderBrowseResult=%~dp1
)
:: Strip trailing slash if found
IF %folderBrowseResult:~-1%==\ SET folderBrowseResult=%folderBrowseResult:~0,-1%
GOTO :EOF
