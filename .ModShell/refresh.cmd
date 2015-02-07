@ECHO OFF
ECHO.
CD /D !MODSHELL_HOME!
IF /I "!current_project!"=="none" (
    ꞈBG PRINT C "[X] " 7 "You must select a mod project first. \n"
    GOTO :EOF
)
:: Get the Forge version from build.gradle
FOR /F %%S IN ('ꞈsed -n "s/    version = //p" !current_project!\build.gradle') DO (
    SET FORGE_VER=%%S
    SET FORGE_VER=!FORGE_VER:"=!
)
CALL func checkForged
IF "!checkForged!"=="false" (
    ꞈBG PRINT C "[X] " 7 "No existing Forge files found in project. \n"
    ꞈBG PRINT 7 "    For legal reasons, you must provide the ZIP file for Forge sources the first time per mod. \n"
    ꞈBG PRINT 7 "    For best results, be sure to provide the same version of Forge specified with the mod. \n"
    echo.
    ꞈBG PRINT A "[i] " F "!current_project!" 7 " is specified to compile with Forge " F "!FORGE_VER!" 7 ". Please either: \n"
    ꞈBG PRINT 7 "    a) Drag 'forge-!FORGE_VER!-src.zip' (or similar/later) onto this window; \n"
    ꞈBG PRINT 7 "    b) Press enter without entering anything to open a browser GUI; or \n"
    ꞈBG PRINT 7 "    c) Manually type the path to the Forge src folder (TAB auto-completion enabled) \n"
    echo.
    CALL func fileBrowse "Forge source ZIP ?"
    echo.
    IF NOT EXIST "!fileBrowseResult!" (
        ꞈBG PRINT C "[X] " 7 "Invalid file specified. Refresh aborted. \n"
        GOTO :EOF
    )
    ꞈBG PRINT B "[#] " 7 "Extracting files... \n"
    rmdir /S /Q "!TEMP!\modshell" >nul 2>&1
    ꞈunzip "!fileBrowseResult!" -d "%TEMP%\modshell\"
    CALL func checkForged "%TEMP%\modshell"
    IF "!checkForged!"=="false" (
        ꞈBG PRINT C "[X] " 7 "ZIP file is not a valid Forge source archive. Refresh aborted. \n"
        GOTO :EOF
    )
    ꞈBG PRINT B "[#] " 7 "Copying gradle files to " F "!current_project!" 7 "... \n"
    XCOPY "%TEMP%\modshell\gradle\wrapper" "!MODSHELL_HOME!\!current_project!\gradle\wrapper" /I >nul
    COPY "%TEMP%\modshell\gradlew" "!MODSHELL_HOME!\!current_project!\gradlew" >nul
    COPY "%TEMP%\modshell\gradlew.bat" "!MODSHELL_HOME!\!current_project!\gradlew.bat" >nul
    CALL func checkForged
    IF "!checkForged!"=="false" (
        ꞈBG PRINT C "[X] " 7 "Copying files failed for an unknown reason. Refresh aborted. \n"
        GOTO :EOF
    )
    ꞈBG PRINT A "[i] " 7 "Forge files copied successfully to " F "!current_project!" 7 ". \n"
    ECHO.
)

ꞈBG PRINT A "[i] " 7 "ModShell will now run the command: \n"
ꞈBG PRINT F "        gradlew setupDecompWorkspace --refresh-dependencies eclipse \n"
ꞈBG PRINT 7 "    If you wish to run your own command(s), press CTRL+C now to abort. \n"
ꞈBG PRINT 7 "    Otherwise, press any key to begin. \n"
pause>nul
CD /D "!MODSHELL_HOME!\!current_project!"
CALL gradlew.bat setupDecompWorkspace --refresh-dependencies eclipse
CD /D "!MODSHELL_HOME!"
echo.
ꞈBG PRINT A "[i] " 7 "All done^! Mod is now Forged. \n"
CALL func modCheck !current_project!
echo.

