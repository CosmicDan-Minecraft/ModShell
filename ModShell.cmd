@ECHO OFF
IF "%1"=="START" GOTO :START
SETLOCAL ENABLEDELAYEDEXPANSION ENABLEEXTENSIONS
SET current_project=None
PROMPT $C Current$SProject:$S!current_project! $F$_$C$P$F$_$G$S
START "" /MAX CMD /E:ON /V:ON /K "%~0" START
EXIT 

:START
CD /D "%~dp0"
SET MODSHELL_HOME=%CD%
SET PATH=%PATH%;%CD%\~ModShell
:: TODO: Enforce that mod names do NOT have a ! character
COLOR 07
TITLE ModShell
::MODE 100,40
MODE CON:cols=100 lines=1000
CALL :INIT
ꞈBG PRINT F "-------------------------------\n"
ꞈBG PRINT F "--    ModShell v0.1 Alpha    --\n"
ꞈBG PRINT F "-------------------------------\n"
echo.
CALL :echoTask 0 "Scanning for Forge projects... \n"
FOR /D %%D IN (*.*) DO (
    IF EXIST %%D\build.gradle (
        ꞈBG PRINT A "    [i] " F "%%D " 7 "found \n"
        SET _modDir=%%D
        SET _modDirNoSpace=!_modDir: =!
        IF NOT !_modDir!==!_modDirNoSpace! (
            ꞈBG PRINT E "        [^!] " 7 "Mod project has a space in it's directory. This will *VERY* likely cause problems^! \n"
        )
        SET _modDir=
        SET _modDirNoSpace=
    )
)
echo.
echo.
ꞈBG PRINT A "[i] " F "ModShell ready^! Type 'cmds' to see global commands.\n"
::PROMPT $CCurrent$SProject:$S!current_project!$F$_$C$P$F$_$G$S
::pause
::CMD /E:ON /F:ON /V:ON /K

GOTO :EOF

:INIT
CHCP 65001 >nul
IF NOT EXIST "%~dp0\~ModShell\ꞈbg.exe" (
    echo [X] Your Windows version does not have Unicode support for some reason.
    echo     ModShell cannot continue. Press any key to quit.
    pause>nul
    exit
)
CALL :echoTask 0 "Checking environment sanity...\n"

::::::::::::::::::::::
:: Check Windows version
::::::::::::::::::::::
VER | FINDSTR /i " 6\.0\." > nul
IF %ERRORLEVEL% EQU 0 (
    CALL :echoWarn 1 "Windows Vista detected. ModShell is untested on this OS, but should work fine."
    CALL :echoBlank 1 "Regardless, if you encounter any errors please report them :)"
    GOTO :VERSION_OK
)
VER | FINDSTR /i " 6\.1\." > nul
IF %ERRORLEVEL% EQU 0 (
    CALL :echoInfo 1 "Windows 7 detected"
    GOTO :VERSION_OK
)
VER | FINDSTR /i " 6\.2\." > nul
IF %ERRORLEVEL% EQU 0 (
    CALL :echoWarn 1 "Windows 8 detected. ModShell is untested on this OS, but should work fine."
    CALL :echoBlank 1 "Regardless, if you encounter any errors please report them :)"
    GOTO :VERSION_OK
)
VER | FINDSTR /i " 5\.2\." > nul
IF %ERRORLEVEL% EQU 0 (
    CALL :echoError 1 "Windows XP or older detected. ModShell is unsupported on anything before Vista,"
    CALL :echoBlank 1 "and simply cannot be adapted for obsolete versions of Windows. Sorry :("
    echo.
    CALL :echoBlank 1 "Press any key to quit."
    pause>nul
    exit
)
:: Something ancient or Windows 10 alpha or something crazy like ReactOS
CALL :echoError 1 "Unknown Windows version detected. Please report this error."
echo.
CALL :echoBlank 1 "Press any key to quit."
pause>nul
exit

:VERSION_OK
::::::::::::::::::::::
:: Ensure there is no whitespace in folder path
::::::::::::::::::::::
SET _currentDir=%~dp0
SET _currentDirNoSpace=!_currentDir: =!
IF NOT !_currentDir!==!_currentDirNoSpace! (
    CALL :echoError 1 "Spaces detected in ModShell path. ModShell is currently located at:"
    ꞈBG PRINT F "        !_currentDir:\=\\! \n"
    CALL :echoBlank 1 "This path contains a space in one of it's parent directories. For safety reasons, ModShell"
    CALL :echoBlank 1 "will *not* load. Please move ModShell to a safe location without spaces in the path."
    ꞈBG PRINT 7 "        For example - " F "C:\\MinecraftModding\\ \n"
    echo.
    CALL :echoBlank 1 "Press any key to quit."
    pause>nul
    exit
)
SET _currentDir=
SET _currentDirNoSpace=

::::::::::::::::::::::
:: Create empty config file if required
::::::::::::::::::::::
IF NOT EXIST "%~dp0\ModShell.ini" (
    ꞈBG PRINT "" > "%~dp0\ModShell.ini"
)
SET SETTINGS="%~dp0\ModShell.ini"
::::::::::::::::::::::
:: Check for write permission in current folder
::::::::::::::::::::::
IF NOT EXIST "%~dp0\ModShell.ini" (
    CALL :echoError 1 "Access denied while trying to create ModShell settings. The current folder..."
    ꞈBG PRINT F "        !_currentDir:\=\\! \n"
    CALL :echoBlank 1 "...is either set as read-only, or you are running in a UAC-protected folder (e.g. Desktop)."
    CALL :echoBlank 1 "For safety reasons, ModShell will *not* load. Please move ModShell to a new, full-rights location."
    ꞈBG PRINT 7 "        For example - " F "C:\\MinecraftModding\\ \n"
    echo.
    CALL :echoBlank 1 "Press any key to quit."
    pause>nul
    exit
)
::::::::::::::::::::::
:: Check for 64-bit
::::::::::::::::::::::
IF DEFINED ProgramFiles(x86) (
    CALL :echoInfo 1 "64-bit detected"
) ELSE (
    CALL :echoInfo 1 "32-bit detected"
    CALL :echoError 1 "Sorry, 32-bit is not currently supported."
    CALL :echoBlank 1 "Press any key to quit."
    pause>nul
    exit
)
::::::::::::::::::::::
:: Check JDK versions
::::::::::::::::::::::
CALL :echoTask 1 "Searching for installed JDK's...\n"
FOR /F "skip=2 tokens=2*" %%A IN ('REG QUERY "HKLM\Software\JavaSoft\Java Development Kit\1.7" /v JavaHome') DO (
    SET JAVA_17_PATH=%%B
    CALL :echoInfo 2 "JDK 1.7 found at '!JAVA_17_PATH:\=\\!'"
)
FOR /F "skip=2 tokens=2*" %%A IN ('REG QUERY "HKLM\Software\JavaSoft\Java Development Kit\1.8" /v JavaHome') DO (
    SET JAVA_18_PATH=%%B
    CALL :echoInfo 2 "JDK 1.8 found at '!JAVA_18_PATH:\=\\!'"
)
IF NOT DEFINED JAVA_17_PATH (
    CALL :echoWarn 2 "JDK 1.7 not installed"
)
IF NOT DEFINED JAVA_18_PATH (
    CALL :echoWarn 2 "JDK 1.8 not installed"
)
IF NOT DEFINED JAVA_17_PATH (
    IF NOT DEFINED JAVA_18_PATH (
        CALL :echoError 2 "No JDK installation found"
        CALL :echoBlank 2 "Your PC has no JDK installed. Install either JDK 1.7 [if using Forge for 1.7.10]"
        CALL :echoBlank 2 "and/or JDK 1.8 [if using Forge for 1.8] and start ModShell again."
        echo.
        CALL :echoBlank 2 "Restarting your computer is *not* required."
        echo.
        CALL :echoBlank 2 "Press any key to quit."
        pause>nul
        exit
    )
)
::::::::::::::::::::::
:: Check for Git installation
::::::::::::::::::::::
CALL :echoTask 1 "Searching for Git installation...\n"
FOR /F "delims=" %%A IN ('ꞈfindexe git') DO (
    SET GIT_PATH=%%A
)
IF DEFINED GIT_PATH (
    CALL :echoInfo 2 "Git found at '!GIT_PATH:\=\\!' - Git integration enabled."
) ELSE (
    CALL :echoWarn 2 "Git installation not found - Git integration disabled."
)
::::::::::::::::::::::
:: Check for Eclipse installation
::::::::::::::::::::::
CALL :echoTask 1 "Checking for Eclipse installation...\n"
CALL func settings get eclipse eclipse_path
IF "!eclipse_path!"=="" (
    CALL :echoWarn 2 "Eclipse path not yet defined. You can either:"
    CALL :echoBlank 2 "a) Drag eclipse.exe or the Eclipse directory onto this window;"
    CALL :echoBlank 2 "b) Press enter without entering anything to open a browser GUI; or"
    CALL :echoBlank 2 "c) Manually type the path to your Eclipse folder/exe (TAB auto-completion enabled)"
    CALL func folderBrowse "Eclipse IDE directory?"
    SET eclipse_path=!folderBrowseResult!
    SET folderBrowseResult=
)
IF NOT EXIST "!eclipse_path!\eclipse.exe" (
    CALL :echoError 2 "Eclipse installation not found. Please install Eclipse and restart ModShell."
    CALL :echoBlank 2 "Press any key to quit."
    pause>nul
    exit
) ELSE (
    CALL :echoInfo 2 "Eclipse installation found at '!eclipse_path:\=\\!'"
    CALL func settings set eclipse eclipse_path
)
echo.
echo.
GOTO :EOF

:echoTask
SET /A _num=%1-1
FOR /L %%C IN (0,1,!_num!) DO ꞈBG PRINT "    "
ꞈBG PRINT B "[#] " 7 "%~2"
SET _num=
GOTO :EOF

:echoTaskOk
ꞈBG PRINT F " %~1 \n"
GOTO :EOF

:echoInfo
SET /A _num=%1-1
FOR /L %%C IN (0,1,!_num!) DO ꞈBG PRINT "    "
ꞈBG PRINT A "[i] " 7 "%~2 \n"
SET _num=
GOTO :EOF

:echoWarn
SET /A _num=%1-1
FOR /L %%C IN (0,1,!_num!) DO ꞈBG PRINT "    "
ꞈBG PRINT E "[^!] " 7 "%~2 \n"
SET _num=
GOTO :EOF

:echoError
SET /A _num=%1-1
FOR /L %%C IN (0,1,!_num!) DO ꞈBG PRINT "    "
ꞈBG PRINT C "[X] " 7 "%~2 \n"
SET _num=
GOTO :EOF

:echoBlank
SET /A _num=%1-1
FOR /L %%C IN (0,1,!_num!) DO ꞈBG PRINT "    "
ꞈBG PRINT 7 "    %~2\n"
SET _num=
GOTO :EOF
