set "params=%*" && cd /d "%CD%" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/C cd ""%CD%"" && %~s0 %params%", "", "runas", 1 >>"%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
@ECHO OFF
TITLE Registry[REG]_Batch___English(Administrator)

GOTO MAIN

:MAIN
CLS
ECHO.
ECHO ==============================================================
ECHO                           Choose
ECHO ==============================================================
ECHO.
ECHO --------------------------------------------------------------
ECHO [1] Management Registry Keys
ECHO [2] Management Registry Value
ECHO --------------------------------------------------------------
ECHO.
CHOICE /C 21 /N /M "Choose Function[1~2]: "
IF ERRORLEVEL 2 (
	GOTO Switch_Registry_Keys
)ELSE (
	GOTO Switch_Registry_Value
)


::REM ===============================================================================================================================
::REM =========================================================Registry_Keys=========================================================
::REM ===============================================================================================================================


:Switch_Registry_Keys
CLS
ECHO.
ECHO =======================================================
ECHO.
CHOICE /C 4321 /N /M "[1]Add Registry_Keys [2]Delete Registry_Keys [3]Rename Registry_Keys [4]Back Menu: "
IF ERRORLEVEL 4 (
	GOTO Add-Registry_Keys-Ask
)ELSE IF ERRORLEVEL 3 (
	GOTO Delete-Registry_Keys-Ask
)ELSE IF ERRORLEVEL 2 (
	GOTO Rename-Registry_Keys-Ask
)ELSE IF ERRORLEVEL 1 (
	GOTO MAIN
)


::REM =======================================Add-Registry_Keys=======================================


:Add-Registry_Keys-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
SET /P Reg_Keys="Input Reg_Keys Path: "
IF "%Reg_Keys%" EQU "" (ECHO. && ECHO Plese Input Reg_Keys Path! && PAUSE && GOTO Add-Registry_Keys)
ECHO.

CALL :Is_Exist_Registry_Keys REM Confirm Path Exist
IF %ERRORLEVEL% NEQ 0 (
	REM No exist than create
	CALL :Add-Registry_Keys-Add
)ELSE (
	REM Exist than ask overwrite origin Keys
	CALL :Add-Registry_Keys-OverWrite-Ask
)
ECHO. && PAUSE && GOTO MAIN

:Add-Registry_Keys-Add
ECHO.
ECHO Create...
ECHO.
powershell -command New-Item -Path Registry::'%Reg_Keys%'
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO Create Fail!
)ELSE (
	ECHO. && ECHO Create Success!
)
EXIT /B

:Add-Registry_Keys-OverWrite-Ask
ECHO.
CHOICE /C NY /N /M "Current exist same Keys! Do you want to overwrite?[Y/N]: "
IF ERRORLEVEL 2 (
	CALL :Add-Registry_Keys-OverWrite
)ELSE IF ERRORLEVEL 1 (
	ECHO.
	ECHO Cancel Success!
)
EXIT /B

:Add-Registry_Keys-OverWrite
ECHO.
ECHO Overwrite...
ECHO.
powershell -command New-Item -Path Registry::'%Reg_Keys%' -Force
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO Overwrite Fail!
)ELSE (
	ECHO. && ECHO Overwrite Success!
)
EXIT /B


::REM =======================================Delete-Registry_Keys====================================


:Delete-Registry_Keys-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
SET /P Reg_Keys="Input Reg_Keys Path: "
IF "%Reg_Keys%" EQU "" (ECHO. && ECHO Plese Input Reg_Keys Path! && PAUSE && GOTO Delete-Registry_Keys-Ask)
ECHO.

CALL :Is_Exist_Registry_Keys REM Confirm Path Exist
IF %ERRORLEVEL% NEQ 0 (
	REM No exist, no need to delete!
	ECHO.
	ECHO Path no exist¡ANo need to delete!
)ELSE (
	REM Exist¡ACan delete!
	CALL :Delete-Registry_Keys-Del-Ask
)
ECHO. && PAUSE && GOTO MAIN

:Delete-Registry_Keys-Del-Ask
ECHO.
CALL :Is_Exist_Registry_SubKeys
IF %Sum% == 0 (
	REM No exist subkeys¡Acan delete!
	ECHO.
	ECHO Confirmed no subkeys in Keys¡Adelete...
	ECHO.
	TIMEOUT /T 2 /NOBREAK > nul 2>&1
	CALL :Delete-Registry_Keys_And_SubKeys-Del
)ELSE (
	REM Subkeys is exist¡AConfirm del!
	CALL :Delete-Registry_SubKeys-Del-Ask
)
EXIT /B

:Delete-Registry_SubKeys-Del-Ask
CALL :ALL_Registry_SubKeys
CHOICE /C 4321 /N /M "The keys includes others subkeys! [1]Delete designate subkeys [2]Delete all subkeys [3]Delete all subkeys and keys [4]Back menu: "
IF ERRORLEVEL 4 (
	CALL :Delete-Registry_Some_SubKeys-Del
)ELSE IF ERRORLEVEL 3 (
	CALL :Delete-Registry_All_SubKeys-Del
)ELSE IF ERRORLEVEL 2 (
	CALL :Delete-Registry_Keys_And_SubKeys-Del
)ELSE IF ERRORLEVEL 1 (
	GOTO MAIN
)

EXIT /B

:Delete-Registry_Some_SubKeys-Del
CLS
ECHO.
ECHO =======================================================
CALL :ALL_Registry_SubKeys
SET /P Reg_SubKeys="Input Reg_SubKeys Name: "
IF "%Reg_Keys%" EQU "" (ECHO. && ECHO Plese Input Reg_SubKeys Name! && PAUSE && GOTO Delete-Registry_Some_SubKeys-Del)
ECHO.
ECHO Delete subkeys...
ECHO.
powershell -command Remove-Item -Path Registry::'%Reg_SubKeys%'
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO Delete fail!
)ELSE (
	ECHO. && ECHO Delete success!
)
EXIT /B

:Delete-Registry_All_SubKeys-Del
CLS
ECHO.
ECHO =======================================================
CALL :ALL_Registry_SubKeys
ECHO Delete all subkeys...
ECHO.
powershell -command Remove-Item -Path Registry::'%Reg_Keys%\*' -Recurse
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO Delete fail!
)ELSE (
	ECHO. && ECHO Delete success!
)
EXIT /B

:Delete-Registry_Keys_And_SubKeys-Del
CLS
ECHO.
ECHO =======================================================
ECHO Delete all subkeys and keys...
ECHO.
powershell -command Remove-Item -Path Registry::'%Reg_Keys%'
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO Delete fail!
)ELSE (
	ECHO. && ECHO Delete success!
)
EXIT /B


::REM =======================================Rename-Registry_Keys====================================


:Rename-Registry_Keys-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
SET /P Reg_Keys="Input Reg_Keys Path: "
IF "%Reg_Keys%" EQU "" (ECHO. && ECHO Plese Input Reg Keys Path! && PAUSE && GOTO Rename-Registry_Keys-Ask)
ECHO.

CALL :Is_Exist_Registry_Keys REM Confirm Path Exist
IF %ERRORLEVEL% NEQ 0 (
	REM No exist,stop run
	ECHO.
	ECHO Error path¡APlease input correct path!
)ELSE (
	REM Exist¡AContinue
	CALL :Rename-Registry_Keys-NewName-Ask
)
ECHO. && PAUSE && GOTO MAIN

:Rename-Registry_Keys-NewName-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
CALL :Registry_Keys
SET /P Reg_keys-NewName="Input Reg_Keys NewName([E] Return ): "
IF "%Reg_keys-NewName%" EQU "" (
	ECHO. && ECHO Plese Input Reg_keys NewName! && PAUSE && GOTO Rename-Registry_Keys-NewName-Ask
)ELSE IF /I "%Reg_keys-NewName%" EQU "E" (
	GOTO Rename-Registry_Keys-Ask
)
CALL :Is_Exist_Registry_Other_Keys
IF %ERRORLEVEL% NEQ 0 (
	CALL :Rename-Registry_Keys
)ELSE (
	ECHO. && ECHO Current have same name¡Aplease input other name && ECHO. && PAUSE && GOTO Rename-Registry_Keys-NewName-Ask
)
EXIT /B

:Rename-Registry_Keys
ECHO.
ECHO =======================================================
ECHO.
ECHO Rename...
ECHO.
powershell -command Rename-Item -Path Registry::"%Reg_Keys%" -NewName '"%Reg_keys-NewName%"' -passthru
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO Change fail!
)ELSE (
	ECHO. && ECHO Change success!
)
EXIT /B


::REM =======================================Module-Registry_Keys====================================


REM Confirm Path Exist
:Is_Exist_Registry_Keys
powershell -command Get-item -Path Registry::'%Reg_Keys%' > nul 2>&1
EXIT /B

REM Confirm Subkeys Exist
:Is_Exist_Registry_SubKeys
for /F "delims=" %%i IN ('"powershell -command (Get-ChildItem -Path Registry::'%Reg_Keys%' -Recurse).length"') do SET Sum=%%i > nul 2>&1
EXIT /B

REM [Rename]Confirm have repeated name
:Is_Exist_Registry_Other_Keys
Set "Reg_keys_Path=%Reg_Keys:~,-1%"
powershell -command Get-item -Path Registry::'%Reg_keys_Path%%Reg_keys-NewName%' > nul 2>&1
EXIT /B

REM Show All Subkeys
:ALL_Registry_SubKeys
ECHO.
ECHO Keys's all subkeys
ECHO -----------------------------------------
powershell -command Get-ChildItem -Path Registry::'%Reg_Keys%' -Recurse ^| Select-Object Name
ECHO Total Subkeys:%Sum%
ECHO -----------------------------------------
ECHO.
EXIT /B

REM Show keys
:Registry_Keys
ECHO.
ECHO The keys info
ECHO -----------------------------------------
powershell -command Get-Item -Path Registry::'%Reg_Keys%'
ECHO -----------------------------------------
ECHO.
EXIT /B


::REM ===============================================================================================================================
::REM =========================================================Registry Value========================================================
::REM ===============================================================================================================================


:Switch_Registry_Value
CLS
ECHO.
ECHO =======================================================
ECHO.
CHOICE /C 4321 /N /M "[1]Add Registry_Entries [2]Delete Registry_Entries [3]Rename Registry_Entries [4]Back Menu: "
IF ERRORLEVEL 4 (
	GOTO Add-Registry_Vulue-Ask
)ELSE IF ERRORLEVEL 3 (
	GOTO Delete-Registry_Vulue-Ask
)ELSE IF ERRORLEVEL 2 (
	GOTO Rename-Registry_Vulue-Ask
)ELSE IF ERRORLEVEL 1 (
	GOTO MAIN
)


::REM =======================================Add-Registry_Vulue======================================


:Add-Registry_Vulue-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
SET /P Reg_Value_Path="Input registry entries path: "
IF "%Reg_Value_Path%" EQU "" (ECHO. && ECHO Plese input registry entries path! && PAUSE && GOTO Add-Registry_Vulue-Ask)
ECHO.

CALL :Is_Exist_Registry_Value_Path REM Confirm Path Exist
IF %ERRORLEVEL% NEQ 0 (
	REM No exist,stop run
	ECHO.
	ECHO Error path¡Aplease input correct path!
)ELSE (
	REM Exist¡AContinue
	CALL :Add-Registry_Vulue-Name-Ask
)
ECHO. && PAUSE && GOTO MAIN

:Add-Registry_Vulue-Name-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
CALL :ALL_Registry_Value
SET /P Reg_Vulue-Name="Input registry entries name: "
IF "%Reg_Vulue-Name%" EQU "" (ECHO. && ECHO Plese input registry entries name! && PAUSE && GOTO Add-Registry_Vulue-Name-Ask)
CALL :Is_Exist_Registry_Value
IF %ERRORLEVEL% NEQ 0 (
	CALL :Add-Registry_Vulue-Type-Ask
)ELSE (
	ECHO. && ECHO Current have same name¡Aplease input other name! && ECHO. && PAUSE && GOTO Add-Registry_Vulue-Name-Ask
)
EXIT /B

:Add-Registry_Vulue-Type-Ask
ECHO.
ECHO =======================================================
ECHO.
CHOICE /C 7654321 /N /M "Please choose entries type[1]String [2]Binary [3]DWord [4]QWord [5]MultiString [6]ExpandString [7]Back: "
IF ERRORLEVEL 7 (
	SET Vulue_Type=String
)ELSE IF ERRORLEVEL 6 (
	SET Vulue_Type=Binary
)ELSE IF ERRORLEVEL 5 (
	SET Vulue_Type=DWord
)ELSE IF ERRORLEVEL 4 (
	SET Vulue_Type=QWord
)ELSE IF ERRORLEVEL 3 (
	SET Vulue_Type=MultiString
)ELSE IF ERRORLEVEL 2 (
	SET Vulue_Type=ExpandString
)ELSE IF ERRORLEVEL 1 (
	GOTO Add-Registry_Vulue-Name-Ask
)
CALL :Add-Registry_Vulue-Vulues-Ask
EXIT /B

:Add-Registry_Vulue-Vulues-Ask
ECHO.
ECHO =======================================================
ECHO.
SET /P Reg_Vulue-Vulues="Input entries values: "
IF "%Reg_Vulue-Vulues%" EQU "" (ECHO. && ECHO Plese Input entries values! && PAUSE && GOTO Add-Registry_Vulue-Vulues-Ask)
CALL :Add-Registry_Vulue
EXIT /B

:Add-Registry_Vulue
ECHO.
ECHO =======================================================
ECHO.
ECHO Create...
powershell -command New-ItemProperty -Path Registry::"%Reg_Value_Path%" -Name '"%Reg_Vulue-Name%"' -PropertyType "%Vulue_Type%" -Value '"%Reg_Vulue-Vulues%"'
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO Create Fail!
)ELSE (
	ECHO. && ECHO Create Success!
)
EXIT /B


::REM =======================================Delete-Registry_Vulue===================================


:Delete-Registry_Vulue-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
SET /P Reg_Value_Path="Input registry entries path: "
IF "%Reg_Value_Path%" EQU "" (ECHO. && ECHO Plese input entries path! && PAUSE && GOTO Delete-Registry_Vulue-Ask)
ECHO.

CALL :Is_Exist_Registry_Value_Path REM Confirm Path Exist
IF %ERRORLEVEL% NEQ 0 (
	REM No exist,stop run
	ECHO.
	ECHO Error path¡APlease input correct path!
)ELSE (
	REM Exist¡AContinue
	CALL :Del-Registry_Vulue-Name-Ask
)
ECHO. && PAUSE && GOTO MAIN

:Del-Registry_Vulue-Name-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
CALL :ALL_Registry_Value
SET /P Reg_Vulue-Name="Input entries name([E] Return ): "
IF "%Reg_Vulue-Name%" EQU "" (
	ECHO. && ECHO Plese input entries name! && PAUSE && GOTO Del-Registry_Vulue-Name-Ask
)ELSE IF /I "%Reg_Vulue-Name%" EQU "E" (
	GOTO Delete-Registry_Vulue-Ask
)
CALL :Is_Exist_Registry_Value
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO Error name¡Aplease input other name! && ECHO. && PAUSE && GOTO Del-Registry_Vulue-Name-Ask
)ELSE (
	CALL :Del-Registry_Vulue
)
EXIT /B

:Del-Registry_Vulue
ECHO.
ECHO =======================================================
ECHO.
ECHO Delete...
powershell -command Remove-ItemProperty -Path Registry::"%Reg_Value_Path%" -Name '"%Reg_Vulue-Name%"'
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO Delete fail!
)ELSE (
	ECHO. && ECHO Delete success!
)
EXIT /B


::REM =======================================Rename-Registry_Vulue===================================


:Rename-Registry_Vulue-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
SET /P Reg_Value_Path="Input registry entries path: "
IF "%Reg_Value_Path%" EQU "" (ECHO. && ECHO Plese input entries path! && PAUSE && GOTO Rename-Registry_Vulue-Ask)
ECHO.

CALL :Is_Exist_Registry_Value_Path REM Confirm Path Exist
IF %ERRORLEVEL% NEQ 0 (
	REM No exist,stop run
	ECHO.
	ECHO Error path¡APlease input correct path!
)ELSE (
	REM Exist¡AContinue
	CALL :Rename-Registry_Vulue-Name-Ask
)
ECHO. && PAUSE && GOTO MAIN

:Rename-Registry_Vulue-Name-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
CALL :ALL_Registry_Value
SET /P Reg_Vulue-Name="Input entries name([E] Return ): "
IF "%Reg_Vulue-Name%" EQU "" (
	ECHO. && ECHO Plese input entries name! && PAUSE && GOTO Rename-Registry_Vulue-Name-Ask
)ELSE IF /I "%Reg_Vulue-Name%" EQU "E" (
	GOTO Rename-Registry_Vulue-Ask
)
CALL :Is_Exist_Registry_Value
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO Error name¡Aplease input other name! && ECHO. && PAUSE && GOTO Rename-Registry_Vulue-Name-Ask
)ELSE (
	CALL :Rename-Registry_Vulue-NewName-Ask
)
EXIT /B

:Rename-Registry_Vulue-NewName-Ask
ECHO.
ECHO =======================================================
ECHO.
SET /P Reg_Vulue-NewName="Input entries new name([E] Return ): "
IF "%Reg_Vulue-NewName%" EQU "" (
	ECHO. && ECHO Plese input entries new name! && PAUSE && GOTO Rename-Registry_Vulue-NewName-Ask
)ELSE IF /I "%Reg_Vulue-NewName%" EQU "E" (
	GOTO Rename-Registry_Vulue-Name-Ask
)
CALL :Is_Exist_Registry_New_Entries
IF %ERRORLEVEL% NEQ 0 (
	CALL :Rename-Registry_Vulue
)ELSE (
	ECHO. && ECHO Current have same name¡Aplease input other name  && ECHO. && PAUSE && GOTO Rename-Registry_Vulue-Name-Ask
)
EXIT /B

:Rename-Registry_Vulue
ECHO.
ECHO =======================================================
ECHO.
ECHO Rename...
ECHO.
powershell -command Rename-ItemProperty -Path Registry::"%Reg_Value_Path%" -Name '"%Reg_Vulue-Name%"' -NewName '"%Reg_Vulue-NewName%"' -passthru
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO Change fail!
)ELSE (
	ECHO. && ECHO Change Success!
)
EXIT /B


::REM =======================================Module-Registry_Vulue===================================


REM Confirm Path Exist
:Is_Exist_Registry_Value_Path
powershell -command Get-item -Path Registry::'%Reg_Value_Path%' > nul 2>&1
EXIT /B

REM Confirm Entries Exist
:Is_Exist_Registry_Value
powershell -command Get-ItemProperty -Path Registry::'%Reg_Value_Path%' -name '"%Reg_Vulue-Name%"' ^| findstr '"%Reg_Vulue-Name%"' > nul 2>&1
EXIT /B

REM [Rename]Confirm Entries Exist
:Is_Exist_Registry_New_Entries
powershell -command Get-ItemProperty -Path Registry::'%Reg_Value_Path%' -name '"%Reg_Vulue-NewName%"' ^| findstr '"%Reg_Vulue-NewName%"' > nul 2>&1
EXIT /B

:ALL_Registry_Value
ECHO.
ECHO Keys's all entries[If no content,mean no entries]
ECHO -----------------------------------------
powershell -command Get-ItemProperty -Path Registry::'%Reg_Value_Path%'
ECHO -----------------------------------------
ECHO.
EXIT /B