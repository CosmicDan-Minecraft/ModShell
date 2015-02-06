@ECHO OFF
IF "%~1"=="" (
    :: Show all commands
    ECHO.
    echo ------------------------------------------------------------------
    ECHO.
    IF "!current_project!" == "None" (
        ꞈBG PRINT A "[i] " 7 "No mod is currently selected, displaying global commands... \n"
        ECHO.
        CALL :cmds_global
    ) ELSE (
        ꞈBG PRINT A "[i] " 7 "Mod is selected, displaying project commands... \n"
        ECHO.
        CALL :cmds_project
    )
) ELSE (
    ::ꞈBG PRINT A "[i] " 7 "Usage: \n"
    CALL :%~1
)
GOTO :EOF

:cmds_global
CALL :create
ECHO.
CALL :deselect
ECHO.
CALL :home
ECHO.
CALL :select bare
GOTO :EOF

:cmds_project
echo ...Nothing yet!
GOTO :EOF

:create
ꞈBG PRINT A "create \n"
ꞈBG PRINT 7 "    Create a new Forge project. This is an interactive process. \n"
GOTO :EOF

:deselect
ꞈBG PRINT A "deselect \n"
ꞈBG PRINT 7 "    Clears, or 'deselects', the current project selection i.e. returns to global mode. \n"
GOTO :EOF

:home
ꞈBG PRINT A "home \n"
ꞈBG PRINT 7 "    Return to the ModShell home directory. \n"
GOTO :EOF

:select
ꞈBG PRINT A "select " F "[modname] \n"
IF NOT "%~1"=="bare" (
    ꞈBG PRINT 7 "    Where " F "[modname] " 7 "is one of the following: \n"
    FOR /D %%D IN (!MODSHELL_HOME!\*.*) DO (
        IF EXIST %%D\build.gradle (
            SET _hasMod=true
            CALL func trimToFinalElement "%%D"
            ꞈBG PRINT F "        !trimToFinalElementResult! \n"
            SET _modDir=!trimToFinalElementResult!
            SET _modDirNoSpace=!_modDir: =!
            IF NOT !_modDir!==!_modDirNoSpace! (
                ꞈBG PRINT E "            [^!] " 7 "Mod project has a space in it's directory. This will *VERY* likely cause problems^! \n"
            )
            SET _modDir=
            SET _modDirNoSpace=
            SET trimToFinalElementResult=
        )
    )
    IF NOT DEFINED _hasMod (
        ꞈBG PRINT 7 "        [No mods found] \n"
    )
    SET _hasMod=
    ꞈBG PRINT 7 "    - See the " F "create " 7 "command to create a new mod. \n"
) ELSE (
    ꞈBG PRINT 7 "    Where " F "modname " 7 "is the directory name of an existing Forge mod. \n"
    ꞈBG PRINT 7 "    - Type " F "select " 7 "alone to see a list of all mods. \n"
)
ꞈBG PRINT 7 "    - Tab-autocompletion is supported, provided you are in the ModShell home directory. See \n"
ꞈBG PRINT 7 "      the " F "home " 7 "command. \n"
GOTO :EOF
