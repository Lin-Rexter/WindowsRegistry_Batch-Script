set "params=%*" && cd /d "%CD%" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/C cd ""%CD%"" && %~s0 %params%", "", "runas", 1 >>"%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
@ECHO OFF
TITLE Registry[REG]_Batch___English(Administrator)

GOTO MAIN

:MAIN
CLS
ECHO.
ECHO.
ECHO ==============================================================
ECHO                       Choose the function
ECHO ==============================================================
ECHO.
ECHO --------------------------------------------------------------
ECHO [1] Management Registry Keys
ECHO [2] Management Registry Entries
ECHO --------------------------------------------------------------
ECHO.
CHOICE /C 21 /N /M "Choose the function[1~2]:"
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
CHOICE /C 4321 /N /M "[1]Create Registry Keys [2]Delete Registry Keys [3]Rename Registry Keys [4]Back Menu: "
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
SET "Reg_Keys="
SET /P Reg_Keys="Please enter the path of the registry keys[B/b:Back Menu]: "
IF NOT DEFINED Reg_Keys (
	ECHO.
	ECHO Please enter the path!
	ECHO.
	PAUSE
	GOTO Add-Registry_Keys-Ask
)ELSE IF /I "%Reg_Keys%" EQU "B" (
	GOTO Switch_Registry_Keys
)
ECHO.

CALL :Is_Exist_Registry_Keys REM Check the existence of the registry keys
IF %ERRORLEVEL% NEQ 0 (
	REM Not exist, create it
	CALL :Add-Registry_Keys-Add
)ELSE (
	REM Exist, Ask to overwrite it
	CALL :Add-Registry_Keys-OverWrite-Ask
)
ECHO. && PAUSE && GOTO Add-Registry_Keys-Ask

:Add-Registry_Keys-Add
ECHO.
ECHO Create...
ECHO.
powershell -command New-Item -Path Registry::'%Reg_Keys%'
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO Create Registry Keys Fail! 
)ELSE (
	ECHO. && ECHO Create Registry Keys Success!
)
EXIT /B

:Add-Registry_Keys-OverWrite-Ask
ECHO.
CHOICE /C NY /N /M "Registry Keys already exist, do you want to overwrite it?[Y/N]: "
IF ERRORLEVEL 2 (
	CALL :Add-Registry_Keys-OverWrite
)ELSE IF ERRORLEVEL 1 (
	ECHO.
	ECHO Successfully canceled!
)
EXIT /B

:Add-Registry_Keys-OverWrite
ECHO.
ECHO Overwrite...
ECHO.
powershell -command New-Item -Path Registry::'%Reg_Keys%' -Force
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO Overwrite Registry Keys Fail!
)ELSE (
	ECHO. && ECHO Overwrite Registry Keys Success!
)
EXIT /B


::REM =======================================Delete-Registry_Keys====================================


:Delete-Registry_Keys-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
SET "Reg_Keys="
SET /P Reg_Keys="Please enter the path of the registry keys[B/b:Back Menu]: "
IF NOT DEFINED Reg_Keys (
	ECHO. 
	ECHO Please enter the path!
	ECHO.
	PAUSE
	GOTO Delete-Registry_Keys-Ask
)ELSE IF /I "%Reg_Keys%" EQU "B" (
	GOTO Switch_Registry_Keys
)
ECHO.

CALL :Is_Exist_Registry_Keys REM Check the existence of the registry keys
IF %ERRORLEVEL% NEQ 0 (
	REM Not exist, no need to delete
	ECHO.
	ECHO Registry Keys does not exist!
)ELSE (
	REM Exist, delete it
	CALL :Delete-Registry_Keys-Del-Ask
)
ECHO. && PAUSE && GOTO Delete-Registry_Keys-Ask

:Delete-Registry_Keys-Del-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
CALL :Is_Exist_Registry_SubKeys
IF %Sum% EQU 0 (
	REM No subkeys, delete it
	ECHO.
	ECHO Checked no subkeys in the registry keys!
	ECHO.
)ELSE (
	REM Exist subkeys, ask to delete it
	CALL :Delete-Registry_SubKeys-Del-Ask
	GOTO Delete-Registry_Keys-Del-Ask
)

ECHO.
CALL :Is_Exist_Registry_Keys_Value
IF %Sum2% EQU 0 (
	REM Not Entries, delete it
	ECHO.
	ECHO Checked no registry entries in the registry keys, 3 seconds later will delete it!
	ECHO.
	TIMEOUT /T 3 /NOBREAK > nul 2>&1
	CALL :Delete-Registry_Keys_And_SubKeys-Del
)ELSE (
	REM Exist Entries, ask to delete it
	ECHO.
	CALL :Delete-Registry_Vulues-Del-Ask
	GOTO Delete-Registry_Keys-Del-Ask
)
ECHO.
pause
GOTO Delete-Registry_Keys-Ask
EXIT /B

:Delete-Registry_Vulues-Del-Ask
CLS
ECHO.
ECHO Original choose Reg keys: %Reg_Keys%
ECHO.
CALL :Show_Registry_Keys_Value
CHOICE /C NY /N /M "Registry Entries already exist, do you want to delete?[Y/N]: "
IF ERRORLEVEL 2 (
	SET Reg_Value_Path="%Reg_Keys%"
	CALL :Del-Registry_Vulue-Name-Ask
	GOTO Delete-Registry_Keys-Del-Ask
)ELSE IF ERRORLEVEL 1 (
	ECHO.
	ECHO Successfully canceled,3 seconds later will delete it!
	ECHO.
	TIMEOUT /T 3 /NOBREAK > nul 2>&1
	CALL :Delete-Registry_Keys_And_SubKeys-Del
)
ECHO.
pause
EXIT /B

:Delete-Registry_SubKeys-Del-Ask
CLS
ECHO.
ECHO Original choose Reg keys: %Reg_Keys%
ECHO.
CALL :ALL_Registry_SubKeys
CHOICE /C 4321 /N /M "The keys has subkeys! [1]Delete one subkey [2]Delete all subkeys [3]Delete all subkeys and Keys [4]canceled: "
IF ERRORLEVEL 4 (
	CALL :Delete-Registry_Some_SubKeys-Del
)ELSE IF ERRORLEVEL 3 (
	CALL :Delete-Registry_All_SubKeys-Del
)ELSE IF ERRORLEVEL 2 (
	CALL :Delete-Registry_Keys_And_SubKeys-Del
)ELSE IF ERRORLEVEL 1 (
	ECHO.
	ECHO Successfully canceled!
)
EXIT /B

:Delete-Registry_Some_SubKeys-Del
CLS
ECHO.
ECHO =======================================================
CALL :ALL_Registry_SubKeys
SET "Reg_SubKeys="
SET /P Reg_SubKeys="Please enter the path of the subkeys you want to delete[B/b:Back Menu]: "
IF NOT DEFINED Reg_SubKeys (
	ECHO.
	ECHO Please enter the name of the subkeys!
	ECHO.
	PAUSE
	GOTO Delete-Registry_Some_SubKeys-Del
)ELSE IF /I "%Reg_SubKeys%" EQU "B" (
	GOTO Delete-Registry_SubKeys-Del-Ask
)
ECHO.
CALL :Is_Exist_Registry_Keys-B REM Check the existence of the registry subkeys
IF %ERRORLEVEL% NEQ 0 (
	REM Not exist, no need to delete!
	ECHO.
	ECHO Subkeys does not exists in keys, please enter again!
	ECHO.
	PAUSE
	GOTO Delete-Registry_Some_SubKeys-Del
)
ECHO.
CALL :Is_Exist_Registry_SubKeys-B REM Checked registry subkeys has other subkeys
IF %Sum% EQU 0 (
	REM Not exist subkeys,delete!
	ECHO.
	ECHO Checked no other subkeys in the subkeys!
	ECHO.
)ELSE (
	REM Exist subkeys, ask to delete it
	GOTO Delete-Registry_SubKeys-Del-Ask
)
ECHO.
CALL :Is_Exist_Registry_Keys_Value-B REM Checked registry subkeys has other entries
IF %Sum2% EQU 0 (
	REM Not exist entries,delete!
	ECHO.
	ECHO Checked no registry entries in the registry keys, 3 seconds later will delete it!
	ECHO.
	TIMEOUT /T 3 /NOBREAK > nul 2>&1
)ELSE (
	REM Exist Entries, ask to delete it
	ECHO.
	CALL :Delete-Registry_Vulues-Del-Ask-B
	ECHO.
	PAUSE
	GOTO Delete-Registry_Keys-Del-Ask
)
powershell -command Remove-Item -Path Registry::'%Reg_SubKeys%'
IF %ERRORLEVEL% NEQ 0 (
	ECHO.
	ECHO Delete Registry SubKeys Fail!
)ELSE (
	ECHO.
	ECHO Delete Registry SubKeys Success!
)
ECHO.
EXIT /B

:Delete-Registry_Vulues-Del-Ask-B
CLS
CALL :Show_Registry_Keys_Value-B
CHOICE /C NY /N /M "Registry Entries exist in the subkeys, do you want to delete?[Y/N]: "
IF ERRORLEVEL 2 (
	SET Reg_Value_Path="%Reg_SubKeys%"
	CALL :Del-Registry_Vulue-Name-Ask
	ECHO.
	PAUSE
	GOTO Delete-Registry_Keys-Del-Ask
)ELSE IF ERRORLEVEL 1 (
	ECHO.
	ECHO Successfully canceled,3 seconds later will delete it!
	ECHO.
	TIMEOUT /T 3 /NOBREAK > nul 2>&1
	CALL :Delete-Registry_Keys_And_SubKeys-Del-B
)
EXIT /B

:Delete-Registry_All_SubKeys-Del
CLS
ECHO.
ECHO =======================================================
CALL :ALL_Registry_SubKeys
ECHO Delete all subkeys in the registry keys!
ECHO.
powershell -command Remove-Item -Path Registry::'%Reg_Keys%\*' -Recurse
IF %ERRORLEVEL% NEQ 0 (
	ECHO.
	ECHO Delete all subkeys in the registry keys Fail!
)ELSE (
	ECHO.
	ECHO Delete all subkeys in the registry keys Success!
)
EXIT /B

:Delete-Registry_Keys_And_SubKeys-Del
CLS
ECHO.
ECHO =======================================================
ECHO Delete the keys...
ECHO.
powershell -command Remove-Item -Path Registry::'%Reg_Keys%' -Recurse
IF %ERRORLEVEL% NEQ 0 (
	ECHO.
	ECHO Delete Fail!
)ELSE (
	ECHO.
	ECHO Delete Success!
)
EXIT /B

:Delete-Registry_Keys_And_SubKeys-Del-B
CLS
ECHO.
ECHO =======================================================
ECHO Delete the subkeys...
ECHO.
powershell -command Remove-Item -Path Registry::'%Reg_SubKeys%' -Recurse
IF %ERRORLEVEL% NEQ 0 (
	ECHO.
	ECHO Delete Fail!
)ELSE (
	ECHO.
	ECHO Delete Success!
)
EXIT /B


::REM =======================================Rename-Registry_Keys====================================


:Rename-Registry_Keys-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
SET "Reg_Keys="
SET /P Reg_Keys="Please enter the path of the registry keys[B/b:Back Menu]: "
IF NOT DEFINED Reg_Keys (
	ECHO. 
	ECHO Please enter the path!
	ECHO.
	PAUSE
	GOTO Rename-Registry_Keys-Ask
)ELSE IF /I "%Reg_Keys%" EQU "B" (
	GOTO Switch_Registry_Keys
)
ECHO.

CALL :Is_Exist_Registry_Keys REM Check the existence of the registry keys
IF %ERRORLEVEL% NEQ 0 (
	REM Not exist, no need to rename
	ECHO.
	ECHO Registry Keys path does not exist!
)ELSE (
	REM Exist, rename it
	CALL :Rename-Registry_Keys-NewName-Ask
)
ECHO. && PAUSE && GOTO Rename-Registry_Keys-Ask

:Rename-Registry_Keys-NewName-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
CALL :Registry_Keys
SET "Reg_keys-NewName="
SET /P Reg_keys-NewName="Please enter the new name of the registry keys[B/b:Back]: "
IF NOT DEFINED Reg_keys-NewName (
	ECHO.
	ECHO Please enter the new name!
	ECHO.
	PAUSE
	GOTO Rename-Registry_Keys-NewName-Ask
)ELSE IF /I "%Reg_keys-NewName%" EQU "B" (
	GOTO Rename-Registry_Keys-Ask
)
CALL :Is_Exist_Registry_Other_Keys
IF %ERRORLEVEL% NEQ 0 (
	CALL :Rename-Registry_Keys
)ELSE (
	ECHO.
	ECHO The new name already exists, please enter other name!
	ECHO.
	PAUSE
	GOTO Rename-Registry_Keys-NewName-Ask
)
EXIT /B

:Rename-Registry_Keys
ECHO.
ECHO =======================================================
ECHO.
ECHO Rename the registry keys...
ECHO.
powershell -command Rename-Item -Path Registry::"%Reg_Keys%" -NewName '"%Reg_keys-NewName%"' -passthru
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO Rename the registry keys Fail!
)ELSE (
	ECHO. && ECHO Rename the registry keys Success!
)
EXIT /B


::REM =======================================Module-Registry_Keys====================================


REM Check the existence of the registry keys
:Is_Exist_Registry_Keys
powershell -command Get-item -Path Registry::'%Reg_Keys%' > nul 2>&1
EXIT /B

REM Check the existence of the registry keys(Use for subkeys)
:Is_Exist_Registry_Keys-B
powershell -command Get-item -Path Registry::'%Reg_SubKeys%' > nul 2>&1
EXIT /B

REM Check the existence of the subkeys of the registry keys
:Is_Exist_Registry_SubKeys
for /F "delims=" %%i IN ('"powershell -command (Get-ChildItem -Path Registry::'%Reg_Keys%' -Recurse).length"') do SET Sum=%%i > nul 2>&1
EXIT /B

REM Check the existence of the subkeys of the registry keys(Use for subkeys)
:Is_Exist_Registry_SubKeys-B
for /F "delims=" %%i IN ('"powershell -command (Get-ChildItem -Path Registry::'%Reg_SubKeys%' -Recurse).length"') do SET Sum=%%i > nul 2>&1
EXIT /B

REM Check the existence of the registry entries in the registry keys and subkeys
:Is_Exist_Registry_Keys_Value
for /F "delims=" %%k IN ('"powershell -command (reg query "%Reg_Keys%" /s).length"') do SET Sum2=%%k > nul 2>&1
EXIT /B

REM Check the existence of the registry entries in the registry keys and subkeys(Use for subkeys)
:Is_Exist_Registry_Keys_Value-B
for /F "delims=" %%k IN ('"powershell -command (reg query "%Reg_SubKeys%" /s).length"') do SET Sum2=%%k > nul 2>&1
EXIT /B

REM Check the existence of the new name of the registry keys
:Is_Exist_Registry_Other_Keys
REM Get path without keys name
for /F %%a in ("%Reg_Keys%") do SET path1=%%~dpa > nul 2>&1
REM Remove other not reg path
for /F "tokens=* delims=%cd%" %%b in ("%path1%") do SET Reg_keys_Path=H%%b > nul 2>&1
REM Remove spaces
SET "Reg_keys_Path=%Reg_keys_Path:  =%"
powershell -command Get-item -Path Registry::'%Reg_keys_Path%%Reg_keys-NewName%' > nul 2>&1
EXIT /B

REM Show all subkeyss
:ALL_Registry_SubKeys
ECHO.
ECHO The all subkeys of the registry keys:
ECHO -----------------------------------------
powershell -command Get-ChildItem -Path Registry::'%Reg_Keys%' -Recurse ^| Select-Object Name
ECHO Total: %Sum%
ECHO -----------------------------------------
ECHO.
EXIT /B

REM Show Registry Entries
:Show_Registry_Keys_Value
ECHO.
IF %Sum2% NEQ 0 (
	ECHO --------------------------------------------------
	ECHO The registry keys or subkeys has the registry entries:
	ECHO.
	powershell -command Get-ItemProperty -Path Registry::'%Reg_Keys%'
	ECHO --------------------------------------------------
)
EXIT /B

REM Show Registry Entries(Use for subkeys)
:Show_Registry_Keys_Value-B
ECHO.
IF %Sum2% NEQ 0 (
	ECHO --------------------------------------------------
	ECHO The registry keys or subkeys has the registry entries:
	ECHO.
	powershell -command Get-ItemProperty -Path Registry::'%Reg_SubKeys%'
	ECHO --------------------------------------------------
)
EXIT /B

REM Show choose keys
:Registry_Keys
ECHO.
ECHO The choose of keys
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
CHOICE /C 54321 /N /M "[1]Add Registry entries [2]Delete Registry entries [3]Rename Registry entries [4]Change Registry entries value[5]Back Menu"
IF ERRORLEVEL 5 (
	GOTO Add-Registry_Vulue-Ask
)ELSE IF ERRORLEVEL 4 (
	GOTO Delete-Registry_Vulue-Ask
)ELSE IF ERRORLEVEL 3 (
	GOTO Rename-Registry_Vulue-Ask
)ELSE IF ERRORLEVEL 2 (
	GOTO Change-Registry_Vulue-Ask
)ELSE IF ERRORLEVEL 1 (
	GOTO MAIN
)


::REM =======================================Add-Registry_Vulue======================================


:Add-Registry_Vulue-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
SET "Reg_Value_Path="
SET /P Reg_Value_Path="Please enter the path of the registry entries[B/b:Back Menu]: "
IF NOT DEFINED Reg_Value_Path (
	ECHO.
	ECHO Please enter the path!
	ECHO.
	PAUSE 
	GOTO Add-Registry_Vulue-Ask
)ELSE IF /I "%Reg_Value_Path%" EQU "B" (
	GOTO Switch_Registry_Value
)
ECHO.

CALL :Is_Exist_Registry_Value_Path REM Check the existence of the registry entries
IF %ERRORLEVEL% NEQ 0 (
	REM Not exist, enter agein
	ECHO.
	ECHO Registry entries path does not exists, please enter again!
	ECHO.
	PAUSE
	GOTO Add-Registry_Vulue-Ask
)ELSE (
	REM Exist, continue
	CALL :Add-Registry_Vulue-Name-Ask
)
ECHO. && PAUSE && GOTO Add-Registry_Vulue-Ask

:Add-Registry_Vulue-Name-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
CALL :ALL_Registry_Value
SET "Reg_Vulue-Name="
SET /P Reg_Vulue-Name="Please enter the name of the registry entries[B/b:Back]: "
IF NOT DEFINED Reg_Vulue-Name (
	ECHO.
	ECHO Please enter the name!
	ECHO.
	PAUSE
	GOTO Add-Registry_Vulue-Name-Ask
)ELSE IF /I "%Reg_Vulue-Name%" EQU "B" (
	GOTO Add-Registry_Vulue-Ask
)

CALL :Is_Exist_Registry_Value
IF %ERRORLEVEL% NEQ 0 (
	CALL :Add-Registry_Vulue-Type-Ask
)ELSE (
	ECHO.
	ECHO The name already exists, please enter other name!
	ECHO.
	PAUSE
	GOTO Add-Registry_Vulue-Name-Ask
)
EXIT /B

:Add-Registry_Vulue-Type-Ask
ECHO.
ECHO =======================================================
ECHO.
CHOICE /C 7654321 /N /M "Please enter the type of entries [1]String [2]Binary [3]DWord [4]QWord [5]MultiString [6]ExpandString [7]Back: "
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
SET "Reg_Vulue-Vulues="
SET /P Reg_Vulue-Vulues="Please enter the value of the registry entries[B/b:Back]: "
IF NOT DEFINED Reg_Vulue-Vulues (
	ECHO.
	ECHO Please enter the value!
	ECHO.
	PAUSE
	GOTO Add-Registry_Vulue-Vulues-Ask
)ELSE IF /I "%Reg_Vulue-Vulues%" EQU "B" (
	GOTO Add-Registry_Vulue-Type-Ask
)
CALL :Add-Registry_Vulue
EXIT /B

:Add-Registry_Vulue
ECHO.
ECHO =======================================================
ECHO.
ECHO Create...
powershell -command New-ItemProperty -Path Registry::"%Reg_Value_Path%" -Name '"%Reg_Vulue-Name%"' -PropertyType "%Vulue_Type%" -Value '"%Reg_Vulue-Vulues%"'
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO Create failed!
)ELSE (
	ECHO. && ECHO Create success!
)
EXIT /B


::REM =======================================Delete-Registry_Vulue===================================


:Delete-Registry_Vulue-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
SET "Reg_Value_Path="
SET /P Reg_Value_Path="Please enter the path of the registry entries[B/b:Back Menu]: "
IF NOT DEFINED Reg_Value_Path (
	ECHO.
	ECHO Please enter the path!
	ECHO.
	PAUSE 
	GOTO Delete-Registry_Vulue-Ask
)ELSE IF /I "%Reg_Value_Path%" EQU "B" (
	GOTO Switch_Registry_Value
)
ECHO.

CALL :Is_Exist_Registry_Value_Path REM Check the existence of the registry entries
IF %ERRORLEVEL% NEQ 0 (
	REM Not exist, enter agein
	ECHO.
	ECHO Registry entries path does not exists, please enter again!
)ELSE (
	REM Exist, continue
	CALL :Del-Registry_Vulue-Name-Ask
)
ECHO. && PAUSE && GOTO Delete-Registry_Vulue-Ask

:Del-Registry_Vulue-Name-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
CALL :ALL_Registry_Value
SET "Reg_Vulue-Name="
SET /P Reg_Vulue-Name="Please enter the name of the registry entries[B/b:Back]: "
IF NOT DEFINED Reg_Vulue-Name (
	ECHO.
	ECHO Please enter the name!
	ECHO.
	PAUSE
	GOTO Del-Registry_Vulue-Name-Ask
)ELSE IF /I "%Reg_Vulue-Name%" EQU "B" (
	GOTO Delete-Registry_Vulue-Ask
)
CALL :Is_Exist_Registry_Value
IF %ERRORLEVEL% NEQ 0 (
	ECHO.
	ECHO The name does not exist, please enter other name!
	ECHO.
	PAUSE
	GOTO Del-Registry_Vulue-Name-Ask
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
	ECHO. && ECHO Delete failed!
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
SET "Reg_Value_Path="
SET /P Reg_Value_Path="Please enter the path of the registry entries[B/b:Back Menu]: "
IF NOT DEFINED Reg_Value_Path (
	ECHO.
	ECHO Please enter the path!
	ECHO.
	PAUSE 
	GOTO Rename-Registry_Vulue-Ask
)ELSE IF /I "%Reg_Value_Path%" EQU "B" (
	GOTO Switch_Registry_Value
)
ECHO.

CALL :Is_Exist_Registry_Value_Path REM Check the existence of the registry entries
IF %ERRORLEVEL% NEQ 0 (
	REM Not exist, enter agein
	ECHO.
	ECHO Registry entries path does not exists, please enter again!
)ELSE (
	REM Exist, continue
	CALL :Rename-Registry_Vulue-Name-Ask
)
ECHO. && PAUSE && GOTO Rename-Registry_Vulue-Ask

:Rename-Registry_Vulue-Name-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
CALL :ALL_Registry_Value
SET "Reg_Vulue-Name="
SET /P Reg_Vulue-Name="	Please enter the name of the registry entries[B/b:Back]: "
IF NOT DEFINED Reg_Vulue-Name (
	ECHO.
	ECHO Please enter the name!
	ECHO.
	PAUSE
	GOTO Rename-Registry_Vulue-Name-Ask
)ELSE IF /I "%Reg_Vulue-Name%" EQU "B" (
	GOTO Rename-Registry_Vulue-Ask
)
CALL :Is_Exist_Registry_Value
IF %ERRORLEVEL% NEQ 0 (
	ECHO.
	ECHO The name does not exist, please enter other name!
	ECHO.
	PAUSE
	GOTO Rename-Registry_Vulue-Name-Ask
)ELSE (
	CALL :Rename-Registry_Vulue-NewName-Ask
)
EXIT /B

:Rename-Registry_Vulue-NewName-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
ECHO The chosen name is: "%Reg_Vulue-Name%"
ECHO.
SET "Reg_Vulue-NewName="
SET /P Reg_Vulue-NewName="Please enter the new name of the registry entries[B/b:Back]: "
IF NOT DEFINED Reg_Vulue-NewName (
	ECHO.
	ECHO Please enter the new name!
	ECHO.
	PAUSE
	GOTO Rename-Registry_Vulue-NewName-Ask
)ELSE IF /I "%Reg_Vulue-NewName%" EQU "B" (
	GOTO Rename-Registry_Vulue-Name-Ask
)
CALL :Is_Exist_Registry_New_Entries
IF %ERRORLEVEL% NEQ 0 (
	CALL :Rename-Registry_Vulue
)ELSE (
	ECHO.
	ECHO The new name already exists, please enter other name!
	ECHO.
	PAUSE
	GOTO Rename-Registry_Vulue-Name-Ask
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
	ECHO. && ECHO Rename failed!
)ELSE (
	ECHO. && ECHO Rename success!
)
EXIT /B


::REM =======================================Change-Registry_Vulue===================================


:Change-Registry_Vulue-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
SET "Reg_Value_Path="
SET /P Reg_Value_Path="Please enter the path of the registry entries[B/b:Back Menu]: "
IF NOT DEFINED Reg_Value_Path (
	ECHO.
	ECHO Please enter the path!
	ECHO.
	PAUSE 
	GOTO Change-Registry_Vulue-Ask
)ELSE IF /I "%Reg_Value_Path%" EQU "B" (
	GOTO Switch_Registry_Value
)
ECHO.

CALL :Is_Exist_Registry_Value_Path REM Check the existence of the registry entries
IF %ERRORLEVEL% NEQ 0 (
	REM Not exist, enter agein
	ECHO.
	ECHO Registry entries path does not exists, please enter again!
)ELSE (
	REM Exist, continue
	CALL :Change-Registry_Vulue-Name-Ask
)
ECHO. && PAUSE && GOTO Change-Registry_Vulue-Ask

:Change-Registry_Vulue-Name-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
CALL :ALL_Registry_Value
SET "Reg_Vulue-Name="
SET /P Reg_Vulue-Name="Please enter the name of the registry entries[B/b:Back]: "
IF NOT DEFINED Reg_Vulue-Name (
	ECHO.
	ECHO Please enter the name!
	ECHO.
	PAUSE
	GOTO Change-Registry_Vulue-Name-Ask
)ELSE IF /I "%Reg_Vulue-Name%" EQU "B" (
	GOTO Change-Registry_Vulue-Ask
)

CALL :Is_Exist_Registry_Value
IF %ERRORLEVEL% NEQ 0 (
	ECHO.
	ECHO The name does not exist, please enter other name!
	ECHO.
	PAUSE
	GOTO Change-Registry_Vulue-Name-Ask
)ELSE (
	CALL :Change-Registry_Vulue-NewValue-Ask
)
EXIT /B

:Change-Registry_Vulue-NewValue-Ask
ECHO.
ECHO =======================================================
ECHO.
SET "Reg_Vulue-NewValue="
SET /P Reg_Vulue-NewValue="Please enter the new value of the registry entries[B/b:Back]: "
IF NOT DEFINED Reg_Vulue-NewValue (
	ECHO.
	ECHO Please enter the new value!
	ECHO.
	PAUSE
	GOTO Change-Registry_Vulue-NewValue-Ask
)ELSE IF /I "%Reg_Vulue-NewValue%" EQU "B" (
	GOTO Change-Registry_Vulue-Name-Ask
)
CALL :Change-Registry_Vulue
EXIT /B

:Change-Registry_Vulue
ECHO.
ECHO =======================================================
ECHO.
ECHO Change...
ECHO.
powershell -command Set-ItemProperty -Path Registry::"%Reg_Value_Path%" -Name '"%Reg_Vulue-Name%"' -Value '"%Reg_Vulue-NewValue%"' -passthru
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO Change failed!
)ELSE (
	ECHO. && ECHO Change success!
)
EXIT /B


::REM =======================================Module-Registry_Vulue===================================


REM Check the existence of the registry entries
:Is_Exist_Registry_Value_Path
powershell -command Get-item -Path Registry::'%Reg_Value_Path%' > nul 2>&1
EXIT /B

REM Check the existence of the registry entries
:Is_Exist_Registry_Value
powershell -command Get-ItemProperty -Path Registry::'%Reg_Value_Path%' -name '"%Reg_Vulue-Name%"' ^| findstr '"%Reg_Vulue-Name%"' > nul 2>&1
EXIT /B

REM Check the existence of the new name of the registry keys
:Is_Exist_Registry_New_Entries
powershell -command Get-ItemProperty -Path Registry::'%Reg_Value_Path%' -name '"%Reg_Vulue-NewName%"' ^| findstr '"%Reg_Vulue-NewName%"' > nul 2>&1
EXIT /B

:ALL_Registry_Value
ECHO.
ECHO The all registry entries in the keys[if no entries, means no keys!]
ECHO -----------------------------------------
powershell -command Get-ItemProperty -Path Registry::'%Reg_Value_Path%'
ECHO -----------------------------------------
ECHO.
EXIT /B