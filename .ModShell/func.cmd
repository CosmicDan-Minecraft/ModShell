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
IF "%~3" == "" (
    :: Prompting for an existing directory - supports GUI if entry is empty
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
    :: strip double-quotes
    SET folderBrowseResult=!folderBrowseResult:"=!
    :: strip trailing slash and/or filename
    CALL :STRIP_PATH !folderBrowseResult!
    SET folderBrowseResult=!STRIP_PATH_RESULT!
    SET STRIP_PATH_RESULT=
    GOTO :EOF
    
) ELSE (
    :: Prompting for a new *or* existing directory - a default is given, does *not* support GUI
    IF "!folderBrowseResult!"=="" (
        SET folderBrowseResult="%~3"
    )
    SET folderBrowseResult=!folderBrowseResult:"=!
    IF NOT EXIST !folderBrowseResult! (
        SET /P _confirmFolderBrowse=Create new workspace at '!folderBrowseResult!'? [y/n] 
    ) ELSE (
        SET /P _confirmFolderBrowse=Use existing workspace at '!folderBrowseResult!'? [y/n]
    )
    IF /I "!_confirmFolderBrowse!" NEQ "y" (
        SET folderBrowseResult=
        SET _confirmFolderBrowse=
        GOTO :folderBrowse
    )
    SET _confirmFolderBrowse=
    MKDIR "!folderBrowseResult!" >nul 2>&1
    IF NOT EXIST !folderBrowseResult! (
        :: Error fallback when creating folder - return empty string
        SET folderBrowseResult=
    )
    GOTO :EOF
)

:fileBrowse
SET /P fileBrowseResult=%~2^> 
IF "%~3" == "" (
    :: Prompting for an existing file - supports GUI if entry is empty
    IF NOT EXIST !fileBrowseResult! (
        SET showGui=true
    )
    IF "!fileBrowseResult!"=="" (
        SET showGui=true
    )
    IF DEFINED showGui (
        SET showGui=
        FOR /F "delims=" %%A IN ('ꞈFileToOpen "SET fileBrowseResult=" "!MODSHELL_HOME!\*.zip" "%~2" /noquote /noCRLF') DO %%A
    )
)
GOTO :EOF

:trimToFinalElement
:: Removes the leading path, getting only the final directory/file name
FOR %%F IN ("%~2") DO SET trimToFinalElementResult=%%~nxF
GOTO :EOF

:processEclipseWorkspace
:: TODO
GOTO :EOF

:modCheck
:: Check for spaces in directory path
SET _modDir=%2
SET _modDirNoSpace=!_modDir: =!
IF NOT !_modDir!==!_modDirNoSpace! (
    ꞈBG PRINT E "    [^!] " 7 "Mod project has a space in it's directory. This will *VERY* likely cause problems^! \n"
)
SET _modDir=
SET _modDirNoSpace=
:: Check if mod has been Forged
CALL :checkForged noparam %2
IF "!checkForged!"=="false" (
    ꞈBG PRINT E "    [^!] " 7 "Mod is not yet set up with Forge. \n"
    IF NOT "%~3"=="bare" (
        ꞈBG PRINT 7 "        Please run the " F "refresh " 7 "command to set up Forge for this mod^! \n"
    )
) ELSE (
    :: check that Forge has actually been installed
    CALL :checkForgedAdditional noparam %2
    IF "!checkForgedAdditional!"=="false" (
        ꞈBG PRINT E "    [^!] " 7 "Mod has Forge installed but needs to be set up. \n"
        IF NOT "%~3"=="bare" (
            ꞈBG PRINT 7 "        Please run the " F "refresh " 7 "command to set up Forge for this mod^! \n"
        )
    ) ELSE (
        :: Mod is fully-forged, check for eclipse project
        CALL :checkEclipsed noparam %2
        IF "!checkEclipsed!"=="false" (
            ꞈBG PRINT E "    [^!] " 7 "Mod has Forge installed but only partially set up. \n"
            IF NOT "%~3"=="bare" (
                ꞈBG PRINT 7 "        Please run the " F "refresh " 7 "command to finish the set up for this mod^! \n"
            )
        ) ELSE (
            :: eclipse project exists, ensure it's added to the workspace
            IF NOT EXIST "!eclipse_workspace!\.metadata\.plugins\org.eclipse.core.resources\.projects\%2\.location" (
                ꞈBG PRINT E "    [^!] " 7 "Mod is not yet initialized. \n"
                IF NOT "%~3"=="bare" (
                    ꞈBG PRINT 7 "        Please run the " F "init " 7 "command now to add this Mod to the eclipse workspace. \n"
                )
            )
        )
    )
)
GOTO :EOF

:checkForged
IF "%~2"=="" (
    SET _checkPath=!MODSHELL_HOME!\!current_project!
) ELSE (
    SET _checkPath=%~2
)
SET checkForged=true
IF NOT EXIST "!_checkPath!\gradlew.bat" SET checkForged=false
IF NOT EXIST "!_checkPath!\gradlew" SET checkForged=false
IF NOT EXIST "!_checkPath!\gradle\wrapper\gradle-wrapper.jar" SET checkForged=false
IF NOT EXIST "!_checkPath!\gradle\wrapper\gradle-wrapper.properties" SET checkForged=false
SET _checkPath=
GOTO :EOF

:checkForgedAdditional
IF "%~2"=="" (
    SET _checkPath=!MODSHELL_HOME!\!current_project!
) ELSE (
    SET _checkPath=%~2
)
SET checkForgedAdditional=true
IF NOT EXIST "!_checkPath!\.gradle" SET checkForgedAdditional=false
IF NOT EXIST "!_checkPath!\build" SET checkForgedAdditional=false
GOTO :EOF

:checkEclipsed
IF "%~2"=="" (
    SET _checkPath=!MODSHELL_HOME!\!current_project!
) ELSE (
    SET _checkPath=%~2
)
SET checkEclipsed=true
IF NOT EXIST "!_checkPath!\.classpath" SET checkEclipsed=false
IF NOT EXIST "!_checkPath!\.project" SET checkEclipsed=false
GOTO :EOF

:::::::::::::::::::
:: USED INTERNALLY
:::::::::::::::::::
:STRIP_PATH
:: Strips trailing slashes from a directory path, and also a filename is found
SET STRIP_PATH_RESULT=%1
IF NOT EXIST "%~1\*" (
    :: Not a directory; strip filename from path
    SET STRIP_PATH_RESULT=%~dp1
)
:: Strip trailing slash if found
IF !STRIP_PATH_RESULT:~-1!==\ SET STRIP_PATH_RESULT=!STRIP_PATH_RESULT:~0,-1!
GOTO :EOF
