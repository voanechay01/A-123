@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
title MANAGEMENT: A-123

:: ==================================================
::  ИНИЦИАЛИЗАЦИЯ
:: ==================================================
for /f %%a in ('echo prompt $E ^| cmd /q /k') do set "ESC=%%a"
set "CLR=%ESC%[38;2;255;222;189m"
set "CLD=%ESC%[38;2;212;238;200m"
set "CLE=%ESC%[38;2;251;140;137m"
set "CL0=%ESC%[0m"

set "RES=%~dp0resources"
set "SCRIPT=%RES%\a-123.py"
set "CFG=%RES%\config.py"
set "CFGPS=%RES%\_cfg.ps1"
set "PIDFILE=%RES%\a-123.pid"
set "STOPFLAG=%RES%\stop.flag"
set "LANGFILE=%RES%\lang.txt"
set "CHECKFILE=%RES%\libs.checked"

:: ==================================================
::  ЭТАП 1: ЗАГРУЗКА ЯЗЫКА
:: ==================================================
if exist "%LANGFILE%" (
    set /p "SAVED_LANG="<"%LANGFILE%"
    if /i "!SAVED_LANG!"=="ru" (
        set "LANG=ru"
        goto :LANG_READY
    )
    if /i "!SAVED_LANG!"=="en" (
        set "LANG=en"
        goto :LANG_READY
    )
)

:ASK_LANG
cls
call :HDR
echo.
echo %CLD%[1] РУССКИЙ%CL0%
echo %CLD%[2] ENGLISH%CL0%
echo.
<nul set /p "=%CLD%ВЫБОР / CHOICE: %CL0%"
set "lang_choice=" & set /p "lang_choice="
if "%lang_choice%"=="1" set "LANG=ru"
if "%lang_choice%"=="2" set "LANG=en"
if not defined LANG goto :ASK_LANG
> "%LANGFILE%" echo !LANG!

:LANG_READY
call :LOAD_%LANG%

:: ==================================================
::  ЭТАП 2: ПРОВЕРКА PYTHON
:: ==================================================
:CHECK_PYTHON
cls
call :HDR
echo.
echo %CLD%%T_CHK_PY%%CL0%
python --version >nul 2>&1
if not errorlevel 1 goto :PY_FOUND

echo %CLE%%T_PY_NO%%CL0%
echo.
echo %CLD%%T_ASK_PY%%CL0%
<nul set /p "=%CLD%%T_YN%%CL0%"
set "answer=" & set /p "answer="
if /i "%answer%"=="y" goto :DO_INSTALL_PY
echo %CLE%%T_PY_REQ%%CL0%
pause >nul
exit /b 1

:DO_INSTALL_PY
call :INSTALL_PYTHON
goto :CHECK_PYTHON

:PY_FOUND
echo %CLD%%T_PY_OK%%CL0%
timeout /t 1 /nobreak >nul

:: ==================================================
::  ЭТАП 3: ПРОВЕРКА БИБЛИОТЕК (раз в 24 часа)
:: ==================================================
call :LIBS_NEED_CHECK
if "%SKIP_LIBS%"=="1" goto :GREETING

:CHECK_LIBS
cls
call :HDR
echo.
echo %CLD%%T_CHK_LIB%%CL0%

set "MISSING="
for %%L in (PIL keyboard) do (
    python -c "import %%L" >nul 2>&1
    if errorlevel 1 set "MISSING=!MISSING! %%L"
)

if "%MISSING%"=="" goto :LIBS_OK
echo %CLE%%T_LIB_NO%%MISSING%%CL0%
echo.
echo %CLD%%T_ASK_LIB%%CL0%
<nul set /p "=%CLD%%T_YN%%CL0%"
set "answer=" & set /p "answer="
if /i "%answer%"=="y" call :INSTALL_LIBS
call :TOUCH_CHECKFILE
goto :GREETING

:LIBS_OK
echo %CLD%%T_LIB_OK%%CL0%
call :TOUCH_CHECKFILE
timeout /t 1 /nobreak >nul

:: ==================================================
::  ЭТАП 4: ПРИВЕТСТВИЕ
:: ==================================================
:GREETING
cls
call :HDR
echo.
echo %CLD%%T_GREET%%CL0%
echo.
echo %CLD%%T_CHECKS_OK%%CL0%
echo %CLD%%T_READY%%CL0%
echo.
echo %CLD%%T_PRESS_KEY%%CL0%
pause >nul

:: ==================================================
::  ЭТАП 5: ГЛАВНОЕ МЕНЮ
:: ==================================================
:MENU
call :CHECK_STATUS
cls
call :HDR
echo.
echo %CLD%%T_MENU_A%%CL0%
echo %CLD%%T_MENU_B%%CL0%
echo %CLD%%T_MENU_C%%CL0%
echo %CLD%%T_MENU_D%%CL0%
echo %CLD%%T_MENU_6%%CL0%
echo %CLD%%T_MENU_E%%CL0%
echo.
<nul set /p "=%CLD%%T_CHOICE%%CL0%"
set "choice=" & set /p "choice="

if /i "%choice%"=="1" goto :START
if /i "%choice%"=="2" goto :STOP
if /i "%choice%"=="3" goto :RESTART
if /i "%choice%"=="4" goto :CHK_LIBS_MENU
if "%choice%"=="5" goto :SETTINGS_MENU
if /i "%choice%"=="0" exit /b 0
goto :MENU

:: ==================================================
::  НАСТРОЙКИ
:: ==================================================
:SETTINGS_MENU
cls
call :HDR
echo %CLD%%T_SET_TITLE%%CL0%
echo.
call :LOAD_SET_VALUES
echo %CLD%[1] %T_SET_ANIM%: !A_LBL!%CL0%
echo %CLD%[2] %T_SET_GLOW%: !G_LBL!%CL0%
echo %CLD%[3] %T_SET_MAX%: !M_VAL!%CL0%
echo %CLD%[4] %T_SET_KEY%: !K_VAL!%CL0%
echo %CLD%[5] %T_SET_OPEN%%CL0%
echo %CLD%[6] %T_SET_LANG%%CL0%
echo %CLD%[7] %T_SET_RECHECK%%CL0%
echo %CLD%[0] %T_SET_BACK%%CL0%
echo.
<nul set /p "=%CLD%%T_CHOICE%%CL0%"
set "s_choice=" & set /p "s_choice="

if "%s_choice%"=="1" call :PS_TOGGLE ANIMATION_ENABLED
if "%s_choice%"=="2" call :PS_TOGGLE ACTIVE_GLOW_ENABLED
if "%s_choice%"=="3" goto :EDIT_MAX
if "%s_choice%"=="4" goto :EDIT_KEY
if "%s_choice%"=="5" goto :OPEN_CFG
if "%s_choice%"=="6" goto :CHANGE_LANG
if "%s_choice%"=="7" goto :FORCE_RECHECK
if "%s_choice%"=="0" goto :MENU
goto :SETTINGS_MENU

:EDIT_MAX
echo.
echo %CLD%%T_SET_MAX_PROMPT%%CL0%
<nul set /p "=%CLD%> %CL0%"
set "newmax=" & set /p "newmax="
if "%newmax%"=="" goto :SETTINGS_MENU
if %newmax% lss 1 goto :SETTINGS_MENU
if %newmax% gtr 4 goto :SETTINGS_MENU
call :PS_WRITE MAX_SHOTS %newmax%
goto :SETTINGS_MENU

:EDIT_KEY
echo.
echo %CLD%%T_SET_KEY_PROMPT%%CL0%
<nul set /p "=%CLD%> %CL0%"
set "newkey=" & set /p "newkey="
if "%newkey%"=="" goto :SETTINGS_MENU
call :PS_WRITE KEY_SHOT "%newkey%"
echo %CLD%%T_SET_KEY_NOTE%%CL0%
timeout /t 2 >nul
goto :SETTINGS_MENU

:OPEN_CFG
start "" notepad "%CFG%"
goto :SETTINGS_MENU

:CHANGE_LANG
echo.
<nul set /p "=%CLD%%T_SET_LANG_PROMPT%%CL0%"
set "newlang=" & set /p "newlang="
if /i "!newlang!"=="ru" (set "LANG=ru" & > "%LANGFILE%" echo ru)
if /i "!newlang!"=="en" (set "LANG=en" & > "%LANGFILE%" echo en)
call :LOAD_%LANG%
goto :SETTINGS_MENU

:FORCE_RECHECK
if exist "%CHECKFILE%" del "%CHECKFILE%" >nul 2>&1
echo %CLD%%T_SET_RECHECK_DONE%%CL0%
timeout /t 2 >nul
goto :CHECK_LIBS

:: ==================================================
::  CONFIG HELPERS
:: ==================================================
:LOAD_SET_VALUES
for /f "delims=" %%v in ('powershell -NoProfile -ExecutionPolicy Bypass -File "%CFGPS%" read ANIMATION_ENABLED') do set "A_VAL=%%v"
for /f "delims=" %%v in ('powershell -NoProfile -ExecutionPolicy Bypass -File "%CFGPS%" read ACTIVE_GLOW_ENABLED') do set "G_VAL=%%v"
for /f "delims=" %%v in ('powershell -NoProfile -ExecutionPolicy Bypass -File "%CFGPS%" read MAX_SHOTS') do set "M_VAL=%%v"
for /f "delims=" %%v in ('powershell -NoProfile -ExecutionPolicy Bypass -File "%CFGPS%" read KEY_SHOT') do set "K_VAL=%%v"

set "A_LBL=OFF"
if "!A_VAL!"=="1" set "A_LBL=ON"
set "G_LBL=OFF"
if "!G_VAL!"=="1" set "G_LBL=ON"
exit /b 0

:PS_TOGGLE
powershell -NoProfile -ExecutionPolicy Bypass -File "%CFGPS%" toggle %1 >nul
exit /b 0

:PS_WRITE
powershell -NoProfile -ExecutionPolicy Bypass -File "%CFGPS%" write %1 %2 >nul
exit /b 0

:: ==================================================
::  LIBS CHECK AGE
:: ==================================================
:LIBS_NEED_CHECK
set "SKIP_LIBS=0"
if not exist "%CHECKFILE%" exit /b 0
for /f %%a in ('powershell -NoProfile -Command "$h = (New-TimeSpan -Start (Get-Item '%CHECKFILE%').LastWriteTime -End (Get-Date)).TotalHours; if ($h -lt 24) { 'skip' } else { 'check' }"') do set "RESULT=%%a"
if "!RESULT!"=="skip" set "SKIP_LIBS=1"
exit /b 0

:TOUCH_CHECKFILE
> "%CHECKFILE%" echo.
exit /b 0

:: ==================================================
::  ОБРАБОТЧИКИ
:: ==================================================
:CHECK_STATUS
set "STATUS=%T_NOT_RUNNING%"
if not exist "%PIDFILE%" exit /b 0
set /p RUN_PID=<"%PIDFILE%"
tasklist /FI "PID eq !RUN_PID!" 2>nul | find "!RUN_PID!" >nul
if errorlevel 1 goto :STATUS_DEAD
set "STATUS=%T_RUNNING% !RUN_PID!"
exit /b 0
:STATUS_DEAD
del "%PIDFILE%" >nul 2>&1
exit /b 0

:START
call :CHECK_STATUS
if not "!STATUS!"=="%T_NOT_RUNNING%" goto :ALREADY_RUN
if exist "%PIDFILE%" del "%PIDFILE%" >nul 2>&1
if exist "%STOPFLAG%" del "%STOPFLAG%" >nul 2>&1
echo.
echo %CLD%%T_STARTING%%CL0%
start "A-123" python "%SCRIPT%"
set /a tries=0
:WAIT_PID
timeout /t 1 >nul
set /a tries+=1
if exist "%PIDFILE%" goto :STARTED
if %tries% lss 6 goto :WAIT_PID
echo %CLE%%T_START_FAIL%%CL0%
pause >nul
goto :MENU
:STARTED
echo %CLD%%T_STARTED%%CL0%
timeout /t 2 >nul
goto :MENU

:ALREADY_RUN
echo.
echo %CLE%%T_ALREADY_RUN%%CL0%
timeout /t 2 >nul
goto :MENU

:STOP
if not exist "%PIDFILE%" goto :STOP_NO
echo.
echo %CLD%%T_STOPPING%%CL0%
type nul > "%STOPFLAG%"
set /a tries=0
:WAIT_STOP
timeout /t 1 >nul
set /a tries+=1
if not exist "%PIDFILE%" goto :STOPPED
if %tries% lss 3 goto :WAIT_STOP
echo %CLE%%T_KILLING%%CL0%
set /p OLD_PID=<"%PIDFILE%"
taskkill /PID !OLD_PID! /F >nul 2>&1
del "%PIDFILE%" >nul 2>&1
del "%STOPFLAG%" >nul 2>&1
:STOPPED
echo %CLD%%T_STOPPED%%CL0%
timeout /t 2 >nul
goto :MENU
:STOP_NO
echo.
echo %CLE%%T_NOT_RUNNING_MSG%%CL0%
timeout /t 2 >nul
goto :MENU

:RESTART
if exist "%PIDFILE%" (
    set /p OLD_PID=<"%PIDFILE%"
    taskkill /PID !OLD_PID! /F >nul 2>&1
    del "%PIDFILE%" >nul 2>&1
    del "%STOPFLAG%" >nul 2>&1
)
timeout /t 1 >nul
goto :START

:CHK_LIBS_MENU
if exist "%CHECKFILE%" del "%CHECKFILE%" >nul 2>&1
goto :CHECK_LIBS

:INSTALL_PYTHON
echo %CLD%%T_DL_PY%%CL0%
set "PY_URL=https://www.python.org/ftp/python/3.12.9/python-3.12.9-amd64.exe"
set "PY_EXE=%TEMP%\python-installer.exe"
powershell -Command "Invoke-WebRequest '%PY_URL%' -OutFile '%PY_EXE%'"
if not exist "%PY_EXE%" goto :DL_FAIL
echo %CLD%%T_INST_PY%%CL0%
"%PY_EXE%" /quiet InstallAllUsers=0 PrependPath=1 Include_test=0
del "%PY_EXE%"
set "PATH=%LOCALAPPDATA%\Programs\Python\Python312;%LOCALAPPDATA%\Programs\Python\Python312\Scripts;%PATH%"
echo %CLD%%T_INST_PY_OK%%CL0%
timeout /t 2 >nul
exit /b 0
:DL_FAIL
echo %CLE%%T_DL_PY_FAIL%%CL0%
pause >nul
exit /b 1

:INSTALL_LIBS
echo %CLD%%T_UPG_PIP%%CL0%
python -m pip install --upgrade pip
echo %CLD%%T_INST_LIB%%CL0%
python -m pip install --upgrade Pillow keyboard
if errorlevel 1 goto :LIB_FAIL
echo %CLD%%T_INST_LIB_OK%%CL0%
timeout /t 2 >nul
exit /b 0
:LIB_FAIL
echo %CLE%%T_INST_LIB_FAIL%%CL0%
pause >nul
exit /b 1

:: ==================================================
::  ШАПКА
:: ==================================================
:HDR
echo.
echo %CLD%█▀▄▀█ █▀▀█ █▀▀▄ █▀▀█ █▀▀▀ █▀▀ █▀▄▀█ █▀▀ █▀▀▄ ▀▀█▀▀%CL0%
echo %CLD%█ ▀ █ █▄▄█ █  █ █▄▄█ █ ▀█ █▀▀ █ ▀ █ █▀▀ █  █   █%CL0%
echo %CLD%▀   ▀ ▀  ▀ ▀  ▀ ▀  ▀ ▀▀▀▀ ▀▀▀ ▀   ▀ ▀▀▀ ▀  ▀   ▀%CL0%
echo.
if "%LANG%"=="ru" echo %CLD%СИСТЕМА УПРАВЛЕНИЯ: A-123.%CL0%
if "%LANG%"=="en" echo %CLD%MANAGEMENT SYSTEM: A-123.%CL0%
exit /b 0

:: ==================================================
::  РУССКИЙ
:: ==================================================
:LOAD_ru
set "T_CHK_PY=[I] ПРОВЕРКА PYTHON..."
set "T_PY_OK=[OK] PYTHON НАЙДЕН."
set "T_PY_NO=[X] PYTHON НЕ НАЙДЕН."
set "T_ASK_PY=УСТАНОВИТЬ PYTHON СЕЙЧАС?"
set "T_YN=(Y/N): "
set "T_PY_REQ=[X] PYTHON НЕ УСТАНОВЛЕН. ПРОГРАММА НЕ МОЖЕТ БЫТЬ ЗАПУЩЕНА."
set "T_CHK_LIB=[I] ПРОВЕРКА БИБЛИОТЕК..."
set "T_LIB_OK=[OK] ВСЕ БИБЛИОТЕКИ НА МЕСТЕ."
set "T_LIB_NO=[X] ОТСУТСТВУЮТ БИБЛИОТЕКИ: "
set "T_ASK_LIB=УСТАНОВИТЬ ИХ СЕЙЧАС?"
set "T_GREET=ДОБРО ПОЖАЛОВАТЬ В СИСТЕМУ УПРАВЛЕНИЯ A-123."
set "T_CHECKS_OK=ВСЕ ПРОВЕРКИ ПРОЙДЕНЫ УСПЕШНО."
set "T_READY=СИСТЕМА ГОТОВА К РАБОТЕ."
set "T_PRESS_KEY=НАЖМИТЕ ЛЮБУЮ КЛАВИШУ ДЛЯ ВХОДА В МЕНЮ..."
set "T_STATUS=СТАТУС:"
set "T_CLASS=КЛАССИФИКАЦИЯ: PYTHON."
set "T_RUNNING=РАБОТАЕТ, PID:"
set "T_NOT_RUNNING=НЕ ЗАПУЩЕН"
set "T_NOT_RUNNING_MSG=[X] НЕ ЗАПУЩЕНО."
set "T_MENU_A=[1] ЗАПУСТИТЬ"
set "T_MENU_B=[2] ОСТАНОВИТЬ"
set "T_MENU_C=[3] ПЕРЕЗАПУСТИТЬ"
set "T_MENU_D=[4] ПРОВЕРКА БИБЛИОТЕК"
set "T_MENU_6=[5] НАСТРОЙКИ"
set "T_MENU_E=[0] ВЫХОД"
set "T_CHOICE=ВЫБОР: "
set "T_ALREADY_RUN=[X] УЖЕ ЗАПУЩЕНО."
set "T_STARTING=ЗАПУСКАЮ A-123.PY..."
set "T_STARTED=[OK] ЗАПУЩЕНО."
set "T_START_FAIL=[X] СКРИПТ НЕ ЗАПУСТИЛСЯ ЗА 6 СЕК."
set "T_STOPPING=ОСТАНАВЛИВАЮ..."
set "T_KILLING=НЕ ОТВЕЧАЕТ, УБИВАЮ ПРИНУДИТЕЛЬНО..."
set "T_STOPPED=[OK] ОСТАНОВЛЕНО."
set "T_DL_PY=СКАЧИВАЮ УСТАНОВЩИК PYTHON..."
set "T_DL_PY_FAIL=[X] НЕ УДАЛОСЬ СКАЧАТЬ PYTHON."
set "T_INST_PY=УСТАНАВЛИВАЮ PYTHON (ТИХАЯ УСТАНОВКА)..."
set "T_INST_PY_OK=[OK] PYTHON УСТАНОВЛЕН."
set "T_UPG_PIP=ОБНОВЛЯЮ PIP..."
set "T_INST_LIB=УСТАНАВЛИВАЮ БИБЛИОТЕКИ..."
set "T_INST_LIB_OK=[OK] БИБЛИОТЕКИ УСТАНОВЛЕНЫ."
set "T_INST_LIB_FAIL=[X] ОШИБКА УСТАНОВКИ БИБЛИОТЕК."
set "T_SET_TITLE=НАСТРОЙКИ A-123.PY"
set "T_SET_ANIM=АНИМАЦИЯ"
set "T_SET_GLOW=ОБВОДКА НОВОГО"
set "T_SET_MAX=МАКС. СКРИНОВ"
set "T_SET_KEY=ХОТКЕЙ"
set "T_SET_OPEN=ОТКРЫТЬ CONFIG.PY"
set "T_SET_LANG=СМЕНИТЬ ЯЗЫК (RU/EN)"
set "T_SET_RECHECK=ПРОВЕРИТЬ БИБЛИОТЕКИ ЗАНОВО"
set "T_SET_BACK=НАЗАД"
set "T_SET_MAX_PROMPT=ВВЕДИТЕ ЧИСЛО ОТ 1 ДО 4:"
set "T_SET_KEY_PROMPT=ВВЕДИТЕ КЛАВИШУ (НАПРИМЕР: z, x, q):"
set "T_SET_KEY_NOTE=ПЕРЕЗАПУСТИ СКРИПТ ДЛЯ ПРИМЕНЕНИЯ."
set "T_SET_LANG_PROMPT=ВВЕДИТЕ ru ИЛИ en: "
set "T_SET_RECHECK_DONE=МЕТКА СБРОШЕНА. ПРОВЕРКА..."
exit /b 0

:: ==================================================
::  ENGLISH
:: ==================================================
:LOAD_en
set "T_CHK_PY=[I] CHECKING PYTHON..."
set "T_PY_OK=[OK] PYTHON FOUND."
set "T_PY_NO=[X] PYTHON NOT FOUND."
set "T_ASK_PY=INSTALL PYTHON NOW?"
set "T_YN=(Y/N): "
set "T_PY_REQ=[X] PYTHON IS NOT INSTALLED."
set "T_CHK_LIB=[I] CHECKING LIBRARIES..."
set "T_LIB_OK=[OK] ALL LIBRARIES ARE PRESENT."
set "T_LIB_NO=[X] MISSING LIBRARIES: "
set "T_ASK_LIB=INSTALL THEM NOW?"
set "T_GREET=WELCOME TO MANAGEMENT SYSTEM A-123."
set "T_CHECKS_OK=ALL CHECKS PASSED SUCCESSFULLY."
set "T_READY=THE SYSTEM IS READY."
set "T_PRESS_KEY=PRESS ANY KEY TO ENTER THE MENU..."
set "T_STATUS=STATUS:"
set "T_CLASS=CLASSIFICATION: PYTHON."
set "T_RUNNING=RUNNING, PID:"
set "T_NOT_RUNNING=NOT RUNNING"
set "T_NOT_RUNNING_MSG=[X] NOT RUNNING."
set "T_MENU_A=[1] START"
set "T_MENU_B=[2] STOP"
set "T_MENU_C=[3] RESTART"
set "T_MENU_D=[4] CHECK LIBRARIES"
set "T_MENU_6=[5] SETTINGS"
set "T_MENU_E=[0] EXIT"
set "T_CHOICE=CHOICE: "
set "T_ALREADY_RUN=[X] ALREADY RUNNING."
set "T_STARTING=STARTING A-123.PY..."
set "T_STARTED=[OK] STARTED."
set "T_START_FAIL=[X] SCRIPT DID NOT START IN 6 SEC."
set "T_STOPPING=STOPPING..."
set "T_KILLING=NOT RESPONDING, FORCE KILLING..."
set "T_STOPPED=[OK] STOPPED."
set "T_DL_PY=DOWNLOADING PYTHON INSTALLER..."
set "T_DL_PY_FAIL=[X] FAILED TO DOWNLOAD PYTHON."
set "T_INST_PY=INSTALLING PYTHON (SILENT)..."
set "T_INST_PY_OK=[OK] PYTHON INSTALLED."
set "T_UPG_PIP=UPGRADING PIP..."
set "T_INST_LIB=INSTALLING LIBRARIES..."
set "T_INST_LIB_OK=[OK] LIBRARIES INSTALLED."
set "T_INST_LIB_FAIL=[X] ERROR INSTALLING LIBRARIES."
set "T_SET_TITLE=A-123.PY SETTINGS"
set "T_SET_ANIM=ANIMATION"
set "T_SET_GLOW=GLOW ON NEWEST"
set "T_SET_MAX=MAX SHOTS"
set "T_SET_KEY=HOTKEY"
set "T_SET_OPEN=OPEN CONFIG.PY"
set "T_SET_LANG=CHANGE LANGUAGE (RU/EN)"
set "T_SET_RECHECK=RECHECK LIBRARIES"
set "T_SET_BACK=BACK"
set "T_SET_MAX_PROMPT=ENTER NUMBER 1 TO 4:"
set "T_SET_KEY_PROMPT=ENTER KEY (E.G. z, x, q):"
set "T_SET_KEY_NOTE=RESTART SCRIPT TO APPLY."
set "T_SET_LANG_PROMPT=ENTER ru OR en: "
set "T_SET_RECHECK_DONE=MARKER RESET. CHECKING..."
exit /b 0
