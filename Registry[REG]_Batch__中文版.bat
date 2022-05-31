set "params=%*" && cd /d "%CD%" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/C cd ""%CD%"" && %~s0 %params%", "", "runas", 1 >>"%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
@ECHO OFF
TITLE Registry[REG]_Batch__中文版(Administrator)

GOTO MAIN

:MAIN
CLS
ECHO.
ECHO.
ECHO ==============================================================
ECHO                           選擇功能
ECHO ==============================================================
ECHO.
ECHO --------------------------------------------------------------
ECHO [1] 管理機碼
ECHO [2] 管理登錄值
ECHO --------------------------------------------------------------
ECHO.
CHOICE /C 21 /N /M "選擇功能[1~2]: "
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
CHOICE /C 4321 /N /M "[1]新增機碼 [2]刪除機碼 [3]重新命名機碼 [4]返回菜單: "
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
SET /P Reg_Keys="請輸入要新增的機碼路徑[B/b:Back Menu]: "
IF NOT DEFINED Reg_Keys (
	ECHO.
	ECHO 請輸入機碼路徑!
	ECHO.
	PAUSE
	GOTO Add-Registry_Keys-Ask
)ELSE IF /I "%Reg_Keys%" EQU "B" (
	GOTO Switch_Registry_Keys
)
ECHO.

CALL :Is_Exist_Registry_Keys REM 確認路徑是否存在
IF %ERRORLEVEL% NEQ 0 (
	REM 不存在，建立!
	CALL :Add-Registry_Keys-Add
)ELSE (
	REM 存在，詢問覆蓋!
	CALL :Add-Registry_Keys-OverWrite-Ask
)
ECHO. && PAUSE && GOTO Add-Registry_Keys-Ask

:Add-Registry_Keys-Add
ECHO.
ECHO 創建中...
ECHO.
powershell -command New-Item -Path Registry::'%Reg_Keys%'
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO 創建失敗，請輸入正確路徑!
)ELSE (
	ECHO. && ECHO 創建成功!
)
EXIT /B

:Add-Registry_Keys-OverWrite-Ask
ECHO.
CHOICE /C NY /N /M "已有相同機碼存在! 是否覆蓋?[Y/N]: "
IF ERRORLEVEL 2 (
	CALL :Add-Registry_Keys-OverWrite
)ELSE IF ERRORLEVEL 1 (
	ECHO.
	ECHO 已取消覆蓋!
)
EXIT /B

:Add-Registry_Keys-OverWrite
ECHO.
ECHO 覆蓋中...
ECHO.
powershell -command New-Item -Path Registry::'%Reg_Keys%' -Force
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO 覆蓋失敗!
)ELSE (
	ECHO. && ECHO 覆蓋成功!
)
EXIT /B


::REM =======================================Delete-Registry_Keys====================================


:Delete-Registry_Keys-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
SET "Reg_Keys="
SET /P Reg_Keys="請輸入要刪除的機碼路徑[B/b:Back Menu]: "
IF NOT DEFINED Reg_Keys (
	ECHO. 
	ECHO 請輸入機碼路徑!
	ECHO.
	PAUSE
	GOTO Delete-Registry_Keys-Ask
)ELSE IF /I "%Reg_Keys%" EQU "B" (
	GOTO Switch_Registry_Keys
)
ECHO.

CALL :Is_Exist_Registry_Keys REM 確認路徑是否存在
IF %ERRORLEVEL% NEQ 0 (
	REM 不存在，不需刪除!
	ECHO.
	ECHO 路徑不存在，無須刪除!
)ELSE (
	REM 存在，可刪除!
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
	REM 不存在子機碼，可刪除!
	ECHO.
	ECHO 已確認機碼下無子機碼存在!
	ECHO.
)ELSE (
	REM 存在子機碼，確認是否刪除!
	CALL :Delete-Registry_SubKeys-Del-Ask
	GOTO Delete-Registry_Keys-Del-Ask
)
ECHO.
CALL :Delete-Registry_Keys-Del-Entries-Ask
EXIT /B

:Delete-Registry_Keys-Del-Entries-Ask
ECHO.
CALL :Is_Exist_Registry_Keys_Value
IF %Sum2% EQU 0 (
	REM 不存在機碼項目，可刪除!
	ECHO.
	CHOICE /C NY /N /M "已確認機碼下無項目存在! 是否進行刪除?[Y/N]: "
	IF ERRORLEVEL 2 (
		ECHO.
		CALL :Delete-Registry_Keys_And_SubKeys-Del
	ELSE IF ERRORLEVEL 1 (
		GOTO Delete-Registry_Keys-Ask
	)
)ELSE (
	REM 存在機碼項目，確認是否刪除!
	ECHO.
	CALL :Delete-Registry_Vulues-Del-Ask
	GOTO Delete-Registry_Keys-Del-Entries-Ask
)
ECHO.
pause
GOTO Delete-Registry_Keys-Ask
EXIT /B

:Delete-Registry_Vulues-Del-Ask
CLS
ECHO.
ECHO 原指定機碼: %Reg_Keys%
ECHO.
CALL :Show_Registry_Keys_Value
CHOICE /C NY /N /M "指定機碼下存在項目! 是否轉到刪除項目功能?[Y/N]: "
IF ERRORLEVEL 2 (
	SET Reg_Value_Path="%Reg_Keys%"
	CALL :Del-Registry_Vulue-Name-Ask
	GOTO Delete-Registry_Keys-Del-Ask
)ELSE IF ERRORLEVEL 1 (
	ECHO.
	CHOICE /C NY /N /M "確認不刪除項目! 是否進行刪除機碼?[Y/N]: "
	IF ERRORLEVEL 2 (
		ECHO.
		CALL :Delete-Registry_Keys_And_SubKeys-Del
	ELSE IF ERRORLEVEL 1 (
		echo 123
		pause
		GOTO Delete-Registry_Keys-Ask
	)
)
ECHO.
pause
EXIT /B

:Delete-Registry_Vulues-Del-Ask-B
CLS
CALL :Show_Registry_Keys_Value-B
CHOICE /C NY /N /M "子機碼下存在項目! 是否轉到刪除作業?[Y/N]: "
IF ERRORLEVEL 2 (
	SET Reg_Value_Path="%Reg_SubKeys%"
	CALL :Del-Registry_Vulue-Name-Ask
	ECHO.
	PAUSE
	GOTO Delete-Registry_Keys-Del-Ask
)ELSE IF ERRORLEVEL 1 (
	ECHO.
	CHOICE /C NY /N /M "確認不刪除項目! 是否進行刪除子機碼?[Y/N]: "
	IF ERRORLEVEL 2 (
		ECHO.
		CALL :Delete-Registry_Keys_And_SubKeys-Del-B
	ELSE IF ERRORLEVEL 1 (
		ECHO.
		ECHO 已取消刪除!
		ECHO.
		PAUSE
	)
)
EXIT /B

:Delete-Registry_SubKeys-Del-Ask
CLS
ECHO.
ECHO 原指定機碼: %Reg_Keys%
ECHO.
CALL :ALL_Registry_SubKeys
CHOICE /C 4321 /N /M "指定機碼下存在其他子機碼! [1]刪除指定子機碼 [2]刪除所有子機碼[不包括指定機碼] [3]刪除所有子機碼[包括指定機碼] [4]取消操作: "
IF ERRORLEVEL 4 (
	CALL :Delete-Registry_Some_SubKeys-Del
)ELSE IF ERRORLEVEL 3 (
	CALL :Delete-Registry_All_SubKeys-Del
)ELSE IF ERRORLEVEL 2 (
	CALL :Delete-Registry_Keys_And_SubKeys-Del
)ELSE IF ERRORLEVEL 1 (
	ECHO.
	ECHO 已取消刪除子機碼!
	ECHO.
	PAUSE
	GOTO Delete-Registry_Keys-Del-Entries-Ask
)
EXIT /B

:Delete-Registry_SubKeys-Del-Ask-B
CLS
ECHO.
ECHO 原指定機碼: %Reg_Keys%
ECHO.
ECHO 指定刪除的子機碼: %Reg_SubKeys%
ECHO.
CALL :ALL_Registry_SubKeys-B
CHOICE /C 4321 /N /M "指定子機碼下存在其他子機碼! [1]刪除指定子機碼 [2]刪除所有子機碼[不包括指定機碼] [3]刪除所有子機碼[包括指定機碼] [4]取消操作: "
IF ERRORLEVEL 4 (
	CALL :Delete-Registry_Some_SubKeys-Del-B
)ELSE IF ERRORLEVEL 3 (
	CALL :Delete-Registry_All_SubKeys-Del-B
)ELSE IF ERRORLEVEL 2 (
	CALL :Delete-Registry_Keys_And_SubKeys-Del-B
)ELSE IF ERRORLEVEL 1 (
	ECHO.
	ECHO 已取消操作!
)
EXIT /B

:Delete-Registry_Some_SubKeys-Del
CLS
ECHO.
ECHO =======================================================
CALL :ALL_Registry_SubKeys
SET "Reg_SubKeys="
SET /P Reg_SubKeys="請輸入要刪除的子機碼路徑[B/b:Back Menu]: "
IF NOT DEFINED Reg_SubKeys (
	ECHO.
	ECHO 請輸入子機碼名稱!
	ECHO.
	PAUSE
	GOTO Delete-Registry_Some_SubKeys-Del
)ELSE IF /I "%Reg_SubKeys%" EQU "B" (
	GOTO Delete-Registry_SubKeys-Del-Ask-B
)
ECHO.
CALL :Is_Exist_Registry_Keys-B REM 確認輸入的子機碼路徑是否正確
IF %ERRORLEVEL% NEQ 0 (
	REM 不存在，不需刪除!
	ECHO.
	ECHO 機碼下無此子機碼，請重新輸入!
	ECHO.
	PAUSE
	GOTO Delete-Registry_Some_SubKeys-Del
)
ECHO.
CALL :Delete-Registry_Some_SubKeys-Del-Ask
EXIT /B

:Delete-Registry_Some_SubKeys-Del-B
CLS
ECHO.
ECHO =======================================================
CALL :ALL_Registry_SubKeys-B
SET "Reg_SubKeys="
SET /P Reg_SubKeys="請輸入要刪除的子機碼路徑[B/b:Back Menu]: "
IF NOT DEFINED Reg_SubKeys (
	ECHO.
	ECHO 請輸入子機碼名稱!
	ECHO.
	PAUSE
	GOTO Delete-Registry_Some_SubKeys-Del-B
)ELSE IF /I "%Reg_SubKeys%" EQU "B" (
	GOTO Delete-Registry_SubKeys-Del-Ask-B
)
ECHO.
CALL :Is_Exist_Registry_Keys-B REM 確認輸入的子機碼路徑是否正確
IF %ERRORLEVEL% NEQ 0 (
	REM 不存在，不需刪除!
	ECHO.
	ECHO 子機碼下無此子機碼，請重新輸入!
	ECHO.
	PAUSE
	GOTO Delete-Registry_Some_SubKeys-Del-B
)
ECHO.
CALL :Delete-Registry_Some_SubKeys-Del-Ask
EXIT /B

:Delete-Registry_Some_SubKeys-Del-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
CALL :Is_Exist_Registry_SubKeys
IF %Sum% EQU 0 (
	REM 不存在子機碼，可刪除!
	ECHO.
	ECHO 已確認機碼下無子機碼存在!
	ECHO.
)ELSE (
	REM 存在子機碼，確認是否刪除!
	CALL :Delete-Registry_SubKeys-Del-Ask-B
	GOTO Delete-Registry_Some_SubKeys-Del-Ask
)
ECHO.
CALL :Delete-Registry_Some_SubKeys-Del-Entries-Ask
EXIT /B

:Delete-Registry_Some_SubKeys-Del-Entries-Ask
ECHO.
CALL :Is_Exist_Registry_Keys_Value
IF %Sum2% EQU 0 (
	REM 不存在機碼項目，可刪除!
	ECHO.
	CHOICE /C NY /N /M "已確認機碼下無項目存在! 是否進行刪除子機碼?[Y/N]: "
	IF ERRORLEVEL 2 (
		ECHO.
		CALL :Delete-Registry_Keys_And_SubKeys-Del-B
	ELSE IF ERRORLEVEL 1 (
		ECHO.
		ECHO 已取消刪除!
	)
)ELSE (
	REM 存在機碼項目，確認是否刪除!
	ECHO.
	CALL :Delete-Registry_Vulues-Del-Ask-B
	GOTO Delete-Registry_Some_SubKeys-Del-Entries-Ask
)
ECHO.
pause
EXIT /B

:Delete-Registry_All_SubKeys-Del
CLS
ECHO.
ECHO =======================================================
CALL :ALL_Registry_SubKeys
ECHO 刪除所有子機碼中...
ECHO.
powershell -command Remove-Item -Path Registry::'%Reg_Keys%\*' -Recurse
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO 刪除失敗!
)ELSE (
	ECHO. && ECHO 刪除成功!
)
EXIT /B

:Delete-Registry_All_SubKeys-Del-B
CLS
ECHO.
ECHO =======================================================
CALL :ALL_Registry_SubKeys-B
ECHO 刪除所有子機碼中...
ECHO.
powershell -command Remove-Item -Path Registry::'%Reg_SubKeys%\*' -Recurse
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO 刪除失敗!
)ELSE (
	ECHO. && ECHO 刪除成功!
)
EXIT /B

:Delete-Registry_Keys_And_SubKeys-Del
CLS
ECHO.
ECHO =======================================================
ECHO 刪除機碼中...
ECHO.
powershell -command Remove-Item -Path Registry::'%Reg_Keys%' -Recurse
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO 刪除失敗!
)ELSE (
	ECHO. && ECHO 刪除成功!
)
EXIT /B

:Delete-Registry_Keys_And_SubKeys-Del-B
CLS
ECHO.
ECHO =======================================================
ECHO 刪除子機碼中...
ECHO.
powershell -command Remove-Item -Path Registry::'%Reg_SubKeys%' -Recurse
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO 刪除失敗!
)ELSE (
	ECHO. && ECHO 刪除成功!
)
EXIT /B

::REM =======================================Rename-Registry_Keys====================================


:Rename-Registry_Keys-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
SET "Reg_Keys="
SET /P Reg_Keys="請輸入要重新命名的機碼路徑[B/b:Back Menu]: "
IF NOT DEFINED Reg_Keys (
	ECHO. 
	ECHO 請輸入機碼路徑!
	ECHO.
	PAUSE
	GOTO Rename-Registry_Keys-Ask
)ELSE IF /I "%Reg_Keys%" EQU "B" (
	GOTO Switch_Registry_Keys
)
ECHO.

CALL :Is_Exist_Registry_Keys REM 確認機碼路徑是否存在
IF %ERRORLEVEL% NEQ 0 (
	REM 不存在，停止操作!
	ECHO.
	ECHO 不存在機碼路徑，請重新輸入!
)ELSE (
	REM 存在，繼續執行操作!
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
SET /P Reg_keys-NewName="請輸入更改後的機碼新名稱[輸入E 返回]: "
IF NOT DEFINED Reg_keys-NewName (
	ECHO. && ECHO 請輸入機碼新名稱! && ECHO. && PAUSE && GOTO Rename-Registry_Keys-NewName-Ask
)ELSE IF /I "%Reg_keys-NewName%" EQU "E" (
	GOTO Rename-Registry_Keys-Ask
)
CALL :Is_Exist_Registry_Other_Keys
IF %ERRORLEVEL% NEQ 0 (
	CALL :Rename-Registry_Keys
)ELSE (
	ECHO.
	ECHO 已有相同名稱，請重新更改其他名稱
	ECHO.
	PAUSE
	GOTO Rename-Registry_Keys-NewName-Ask
)
EXIT /B

:Rename-Registry_Keys
ECHO.
ECHO =======================================================
ECHO.
ECHO 重新命名中...
ECHO.
powershell -command Rename-Item -Path Registry::"%Reg_Keys%" -NewName '"%Reg_keys-NewName%"' -passthru
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO 更改失敗!
)ELSE (
	ECHO. && ECHO 更改成功!
)
EXIT /B


::REM =======================================Module-Registry_Keys====================================


REM 確認路徑是否存在
:Is_Exist_Registry_Keys
powershell -command Get-item -Path Registry::'%Reg_Keys%' > nul 2>&1
EXIT /B

REM 確認路徑是否存在(子機碼變數用)
:Is_Exist_Registry_Keys-B
powershell -command Get-item -Path Registry::'%Reg_SubKeys%' > nul 2>&1
EXIT /B

REM 確認子機碼是否存在
:Is_Exist_Registry_SubKeys
for /F "delims=" %%i IN ('"powershell -command (Get-ChildItem -Path Registry::'%Reg_Keys%' -Recurse).length"') do SET Sum=%%i > nul 2>&1
EXIT /B

REM 確認子機碼是否存在(子機碼變數用)
:Is_Exist_Registry_SubKeys-B
for /F "delims=" %%i IN ('"powershell -command (Get-ChildItem -Path Registry::'%Reg_SubKeys%' -Recurse).length"') do SET Sum=%%i > nul 2>&1
EXIT /B

REM 確認機碼內是否存在項目值
:Is_Exist_Registry_Keys_Value
for /F "delims=" %%k IN ('"powershell -command (reg query "%Reg_Keys%" /s).length"') do SET Sum2=%%k > nul 2>&1
EXIT /B

REM 確認機碼內是否存在項目值(子機碼變數用)
:Is_Exist_Registry_Keys_Value-B
for /F "delims=" %%k IN ('"powershell -command (reg query "%Reg_SubKeys%" /s).length"') do SET Sum2=%%k > nul 2>&1
EXIT /B

REM 確認重新命名後的路徑名稱是否衝突
:Is_Exist_Registry_Other_Keys
REM 取得路徑
for /F %%a in ("%Reg_Keys%") do SET path1=%%~dpa > nul 2>&1
REM 去掉REG以外的路徑
for /F "tokens=* delims=%cd%" %%b in ("%path1%") do SET Reg_keys_Path=H%%b > nul 2>&1
REM 去掉空格
SET "Reg_keys_Path=%Reg_keys_Path:  =%"
powershell -command Get-item -Path Registry::'%Reg_keys_Path%%Reg_keys-NewName%' > nul 2>&1
EXIT /B

REM 顯示所有子機碼
:ALL_Registry_SubKeys
ECHO.
ECHO 指定機碼下的所有子機碼
ECHO -----------------------------------------
powershell -command Get-ChildItem -Path Registry::'%Reg_Keys%' -Recurse ^| Select-Object Name
ECHO 子機碼數量:%Sum%
ECHO -----------------------------------------
ECHO.
EXIT /B

REM 顯示所有子機碼(子機碼變數用)
:ALL_Registry_SubKeys-B
ECHO.
ECHO 指定子機碼下的所有子機碼
ECHO -----------------------------------------
powershell -command Get-ChildItem -Path Registry::'%Reg_SubKeys%' -Recurse ^| Select-Object Name
ECHO 子機碼數量:%Sum%
ECHO -----------------------------------------
ECHO.
EXIT /B

REM 顯示機碼內項目值
:Show_Registry_Keys_Value
ECHO.
IF %Sum2% NEQ 0 (
	ECHO --------------------------------------------------
	ECHO 機碼內有項目值!
	ECHO.
	powershell -command Get-ItemProperty -Path Registry::'%Reg_Keys%'
	ECHO --------------------------------------------------
)
EXIT /B

REM 顯示機碼內項目值(子機碼變數用)
:Show_Registry_Keys_Value-B
ECHO.
IF %Sum2% NEQ 0 (
	ECHO --------------------------------------------------
	ECHO 子機碼內有項目值!
	ECHO.
	powershell -command Get-ItemProperty -Path Registry::'%Reg_SubKeys%'
	ECHO --------------------------------------------------
)
EXIT /B

REM 顯示指定機碼
:Registry_Keys
ECHO.
ECHO 指定的機碼
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
CHOICE /C 54321 /N /M "[1]新增機碼項目 [2]刪除機碼項目 [3]重新命名機碼項目 [4]更改機碼項目值 [5]返回菜單: "
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
SET /P Reg_Value_Path="請輸入要新增的機碼項目路徑[B/b:Back Menu]: "
IF NOT DEFINED Reg_Value_Path (
	ECHO.
	ECHO 請輸入機碼項目路徑!
	ECHO.
	PAUSE 
	GOTO Add-Registry_Vulue-Ask
)ELSE IF /I "%Reg_Value_Path%" EQU "B" (
	GOTO Switch_Registry_Value
)
ECHO.

CALL :Is_Exist_Registry_Value_Path REM 確認機碼路徑是否存在
IF %ERRORLEVEL% NEQ 0 (
	REM 不存在，停止操作!
	ECHO.
	ECHO 不存在機碼路徑，請重新輸入!
	ECHO.
	PAUSE
	GOTO Add-Registry_Vulue-Ask
)ELSE (
	REM 存在，繼續執行操作!
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
SET /P Reg_Vulue-Name="請輸入要新增的機碼項目名稱: "
IF NOT DEFINED Reg_Vulue-Name (ECHO. && ECHO 請輸入機碼項目名稱! && ECHO. && PAUSE && GOTO Add-Registry_Vulue-Name-Ask)
CALL :Is_Exist_Registry_Value
IF %ERRORLEVEL% NEQ 0 (CALL :Add-Registry_Vulue-Type-Ask)ELSE (ECHO. && ECHO 項目名已存在，請重新輸入! && ECHO. && PAUSE && GOTO Add-Registry_Vulue-Name-Ask)
EXIT /B

:Add-Registry_Vulue-Type-Ask
ECHO.
ECHO =======================================================
ECHO.
CHOICE /C 7654321 /N /M "請選擇項目類型[1]String [2]Binary [3]DWord [4]QWord [5]MultiString [6]ExpandString [7]Back: "
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
SET /P Reg_Vulue-Vulues="請輸入項目內容值: "
IF NOT DEFINED Reg_Vulue-Vulues (
	ECHO.
	ECHO 請輸入項目值!
	ECHO.
	PAUSE
	GOTO Add-Registry_Vulue-Vulues-Ask
)
CALL :Add-Registry_Vulue
EXIT /B

:Add-Registry_Vulue
ECHO.
ECHO =======================================================
ECHO.
ECHO 創建中...
powershell -command New-ItemProperty -Path Registry::"%Reg_Value_Path%" -Name '"%Reg_Vulue-Name%"' -PropertyType "%Vulue_Type%" -Value '"%Reg_Vulue-Vulues%"'
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO 創建失敗!
)ELSE (
	ECHO. && ECHO 創建成功!
)
EXIT /B


::REM =======================================Delete-Registry_Vulue===================================


:Delete-Registry_Vulue-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
SET "Reg_Value_Path="
SET /P Reg_Value_Path="請輸入要刪除的機碼項目路徑[B/b:Back Menu]: "
IF NOT DEFINED Reg_Value_Path (
	ECHO.
	ECHO 請輸入機碼項目路徑!
	ECHO.
	PAUSE 
	GOTO Delete-Registry_Vulue-Ask
)ELSE IF /I "%Reg_Value_Path%" EQU "B" (
	GOTO Switch_Registry_Value
)
ECHO.

CALL :Is_Exist_Registry_Value_Path REM 確認機碼路徑是否存在
IF %ERRORLEVEL% NEQ 0 (
	REM 不存在，停止操作!
	ECHO.
	ECHO 不存在機碼路徑，請重新輸入!
)ELSE (
	REM 存在，繼續執行操作!
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
SET /P Reg_Vulue-Name="請輸入要刪除的機碼項目名稱[輸入B 返回]: "
IF NOT DEFINED Reg_Vulue-Name (
	ECHO. && ECHO 請輸入機碼項目名稱! && ECHO. && PAUSE && GOTO Del-Registry_Vulue-Name-Ask
)ELSE IF /I "%Reg_Vulue-Name%" EQU "B" (
	GOTO Delete-Registry_Vulue-Ask
)
CALL :Is_Exist_Registry_Value
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO 項目名不存在，請重新輸入! && ECHO. && PAUSE && GOTO Del-Registry_Vulue-Name-Ask)ELSE (CALL :Del-Registry_Vulue)
EXIT /B

:Del-Registry_Vulue
ECHO.
ECHO =======================================================
ECHO.
ECHO 刪除中...
powershell -command Remove-ItemProperty -Path Registry::"%Reg_Value_Path%" -Name '"%Reg_Vulue-Name%"'
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO 刪除失敗!
)ELSE (
	ECHO. && ECHO 刪除成功!
)
EXIT /B


::REM =======================================Rename-Registry_Vulue===================================


:Rename-Registry_Vulue-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
SET "Reg_Value_Path="
SET /P Reg_Value_Path="請輸入要重新命名的機碼項目路徑[B/b:Back Menu]: "
IF NOT DEFINED Reg_Value_Path (
	ECHO.
	ECHO 請輸入機碼項目路徑!
	ECHO.
	PAUSE 
	GOTO Rename-Registry_Vulue-Ask
)ELSE IF /I "%Reg_Value_Path%" EQU "B" (
	GOTO Switch_Registry_Value
)
ECHO.

CALL :Is_Exist_Registry_Value_Path REM 確認機碼路徑是否存在
IF %ERRORLEVEL% NEQ 0 (
	REM 不存在，停止操作!
	ECHO.
	ECHO 不存在機碼路徑，請重新輸入!
)ELSE (
	REM 存在，繼續執行操作!
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
SET /P Reg_Vulue-Name="請輸入要重新命名的機碼項目名稱[輸入E 返回]: "
IF NOT DEFINED Reg_Vulue-Name (
	ECHO. && ECHO 請輸入新機碼項目名稱! && ECHO. && PAUSE && GOTO Rename-Registry_Vulue-Name-Ask
)ELSE IF /I "%Reg_Vulue-Name%" EQU "E" (
	GOTO Rename-Registry_Vulue-Ask
)
CALL :Is_Exist_Registry_Value
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO 項目名不存在，請重新輸入! && ECHO. && PAUSE && GOTO Rename-Registry_Vulue-Name-Ask)ELSE (CALL :Rename-Registry_Vulue-NewName-Ask)
EXIT /B

:Rename-Registry_Vulue-NewName-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
ECHO 選擇的機碼項目: "%Reg_Vulue-Name%"
ECHO.
SET "Reg_Vulue-NewName="
SET /P Reg_Vulue-NewName="請輸入新的的機碼項目名稱[輸入E 返回]: "
IF NOT DEFINED Reg_Vulue-NewName (
	ECHO. && ECHO 請輸入新機碼項目名稱! && ECHO. && PAUSE && GOTO Rename-Registry_Vulue-NewName-Ask
)ELSE IF /I "%Reg_Vulue-NewName%" EQU "E" (
	GOTO Rename-Registry_Vulue-Name-Ask
)
CALL :Is_Exist_Registry_New_Entries
IF %ERRORLEVEL% NEQ 0 (
	CALL :Rename-Registry_Vulue
)ELSE (
	ECHO. && ECHO 項目名已存在，請重新輸入! && ECHO. && PAUSE && GOTO Rename-Registry_Vulue-Name-Ask
)
EXIT /B

:Rename-Registry_Vulue
ECHO.
ECHO =======================================================
ECHO.
ECHO 重新命名中...
ECHO.
powershell -command Rename-ItemProperty -Path Registry::"%Reg_Value_Path%" -Name '"%Reg_Vulue-Name%"' -NewName '"%Reg_Vulue-NewName%"' -passthru
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO 更改失敗!
)ELSE (
	ECHO. && ECHO 更改成功!
)
EXIT /B


::REM =======================================Change-Registry_Vulue===================================


:Change-Registry_Vulue-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
SET "Reg_Value_Path="
SET /P Reg_Value_Path="請輸入要更改的機碼項目值路徑[B/b:Back Menu]: "
IF NOT DEFINED Reg_Value_Path (
	ECHO.
	ECHO 請輸入機碼項目路徑!
	ECHO.
	PAUSE 
	GOTO Change-Registry_Vulue-Ask
)ELSE IF /I "%Reg_Value_Path%" EQU "B" (
	GOTO Switch_Registry_Value
)
ECHO.

CALL :Is_Exist_Registry_Value_Path REM 確認機碼路徑是否存在
IF %ERRORLEVEL% NEQ 0 (
	REM 不存在，停止操作!
	ECHO.
	ECHO 不存在機碼路徑，請重新輸入!
)ELSE (
	REM 存在，繼續執行操作!
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
SET /P Reg_Vulue-Name="請輸入要更改的機碼項目名稱[輸入E 返回]: "
IF NOT DEFINED Reg_Vulue-Name (
	ECHO.
	ECHO 請輸入機碼項目名稱!
	ECHO.
	PAUSE
	GOTO Change-Registry_Vulue-Name-Ask
)ELSE IF /I "%Reg_Vulue-Name%" EQU "E" (
	GOTO Change-Registry_Vulue-Ask
)

CALL :Is_Exist_Registry_Value
IF %ERRORLEVEL% NEQ 0 (
	ECHO.
	ECHO 項目名不存在，請重新輸入!
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
SET /P Reg_Vulue-NewValue="請輸入新的的項目值[輸入E 返回]: "
IF NOT DEFINED Reg_Vulue-NewValue (
	ECHO.
	ECHO 請輸入新項目值!
	ECHO.
	PAUSE
	GOTO Change-Registry_Vulue-NewValue-Ask
)ELSE IF /I "%Reg_Vulue-NewValue%" EQU "E" (
	GOTO Change-Registry_Vulue-Name-Ask
)
CALL :Change-Registry_Vulue
EXIT /B

:Change-Registry_Vulue
ECHO.
ECHO =======================================================
ECHO.
ECHO 更改中...
ECHO.
powershell -command Set-ItemProperty -Path Registry::"%Reg_Value_Path%" -Name '"%Reg_Vulue-Name%"' -Value '"%Reg_Vulue-NewValue%"' -passthru
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO 更改失敗!
)ELSE (
	ECHO. && ECHO 更改成功!
)
EXIT /B


::REM =======================================Module-Registry_Vulue===================================


REM 確認項目路徑是否存在
:Is_Exist_Registry_Value_Path
powershell -command Get-item -Path Registry::'%Reg_Value_Path%' > nul 2>&1
EXIT /B

REM 確認項目是否存在
:Is_Exist_Registry_Value
powershell -command Get-ItemProperty -Path Registry::'%Reg_Value_Path%' -name '"%Reg_Vulue-Name%"' ^| findstr '"%Reg_Vulue-Name%"' > nul 2>&1
EXIT /B

REM 確認重新命名後的項目名稱是否衝突
:Is_Exist_Registry_New_Entries
powershell -command Get-ItemProperty -Path Registry::'%Reg_Value_Path%' -name '"%Reg_Vulue-NewName%"' ^| findstr '"%Reg_Vulue-NewName%"' > nul 2>&1
EXIT /B

:ALL_Registry_Value
ECHO.
ECHO 機碼下的所有項目[如沒有顯示即無項目存在!]
ECHO -----------------------------------------
powershell -command Get-ItemProperty -Path Registry::'%Reg_Value_Path%'
ECHO -----------------------------------------
ECHO.
EXIT /B