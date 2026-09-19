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

set "SCRIPT=a-123.py"
set "PIDFILE=%~dp0a-123.pid"
set "STOPFLAG=%~dp0stop.flag"

:: ==================================================
::  ЭТАП 1: СТАРТ И ВЫБОР ЯЗЫКА
:: ==================================================
:BOOT
cls
call :HDR
echo.
echo %CLD%[1] РУССКИЙ%CL0%
echo %CLD%[2] ENGLISH%CL0%
echo.
<nul set /p "=%CLR%ВЫБОР / CHOICE: %CL0%"
set /p "lang_choice="

if "%lang_choice%"=="1" set "LANG=ru"
if "%lang_choice%"=="2" set "LANG=en"
if not defined LANG goto :BOOT

call :LOAD_%LANG%
goto :CHECK_PYTHON

:: ==================================================
::  ЭТАП 2: ПРОВЕРКА PYTHON
:: ==================================================
:CHECK_PYTHON
cls
call :HDR
echo.
echo %CLR%%T_CHK_PY%%CL0%

python --version >nul 2>&1
if not errorlevel 1 goto :PY_FOUND

echo %CLE%%T_PY_NO%%CL0%
echo.
echo %CLR%%T_ASK_PY%%CL0%
<nul set /p "=%CLD%%T_YN%%CL0%"
set "answer="
set /p "answer="
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
::  ЭТАП 3: ПРОВЕРКА БИБЛИОТЕК
:: ==================================================
:CHECK_LIBS
cls
call :HDR
echo.
echo %CLR%%T_CHK_LIB%%CL0%

set "MISSING="
for %%L in (PIL keyboard) do (
    python -c "import %%L" >nul 2>&1
    if errorlevel 1 set "MISSING=!MISSING! %%L"
)

if "%MISSING%"=="" goto :LIBS_OK
echo %CLE%%T_LIB_NO%%MISSING%%CL0%
echo.
echo %CLR%%T_ASK_LIB%%CL0%
<nul set /p "=%CLD%%T_YN%%CL0%"
set "answer="
set /p "answer="
if /i "%answer%"=="y" goto :DO_INSTALL_LIBS
echo %CLE%%T_LIB_SKIP%%CL0%
timeout /t 2 >nul
goto :GREETING

:DO_INSTALL_LIBS
call :INSTALL_LIBS
goto :GREETING

:LIBS_OK
echo %CLD%%T_LIB_OK%%CL0%
timeout /t 1 /nobreak >nul

:: ==================================================
::  ЭТАП 4: ПРИВЕТСТВИЕ
:: ==================================================
:GREETING
cls
call :HDR
echo.
echo %CLR%%T_GREET%%CL0%
echo.
echo %CLD%%T_CHECKS_OK%%CL0%
echo %CLD%%T_READY%%CL0%
echo.
echo %CLR%%T_PRESS_KEY%%CL0%
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
echo %CLD%%T_MENU_E%%CL0%
echo.
<nul set /p "=%CLD%%T_CHOICE%%CL0%"
set "choice="
set /p "choice="

if /i "%choice%"=="a" goto :START
if /i "%choice%"=="b" goto :STOP
if /i "%choice%"=="c" goto :RESTART
if /i "%choice%"=="d" goto :CHK_LIBS_MENU
if /i "%choice%"=="e" exit /b 0
if /i "%choice%"=="1" goto :START
if /i "%choice%"=="2" goto :STOP
if /i "%choice%"=="3" goto :RESTART
if /i "%choice%"=="4" goto :CHK_LIBS_MENU
if /i "%choice%"=="5" exit /b 0
goto :MENU

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
echo %CLR%%T_STARTING%%CL0%
start "A-123" python "%SCRIPT%"
set /a tries=0
:WAIT_PID
timeout /t 1 >nul
set /a tries+=1
if exist "%PIDFILE%" goto :STARTED
if %tries% lss 6 goto :WAIT_PID

echo %CLE%%T_START_FAIL%%CL0%
pause
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
echo %CLR%%T_STOPPING%%CL0%
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
cls
call :HDR
echo.
echo %CLR%%T_CHK_LIB%%CL0%
set "MISSING="
for %%L in (PIL keyboard) do (
    python -c "import %%L" >nul 2>&1
    if errorlevel 1 set "MISSING=!MISSING! %%L"
)
if "!MISSING!"=="" goto :CHK_OK
echo %CLE%%T_LIB_NO%!MISSING!%CL0%
echo.
echo %CLR%%T_ASK_LIB%%CL0%
<nul set /p "=%CLD%%T_YN%%CL0%"
set "answer="
set /p "answer="
if /i "!answer!"=="y" call :INSTALL_LIBS
pause
goto :MENU

:CHK_OK
echo %CLD%%T_LIB_OK%%CL0%
pause
goto :MENU

:INSTALL_PYTHON
echo %CLR%%T_DL_PY%%CL0%
set "PY_URL=https://www.python.org/ftp/python/3.12.9/python-3.12.9-amd64.exe"
set "PY_EXE=%TEMP%\python-installer.exe"
powershell -Command "Invoke-WebRequest '%PY_URL%' -OutFile '%PY_EXE%'"
if not exist "%PY_EXE%" goto :DL_FAIL
echo %CLR%%T_INST_PY%%CL0%
"%PY_EXE%" /quiet InstallAllUsers=0 PrependPath=1 Include_test=0
del "%PY_EXE%"
set "PATH=%LOCALAPPDATA%\Programs\Python\Python312;%LOCALAPPDATA%\Programs\Python\Python312\Scripts;%PATH%"
echo %CLD%%T_INST_PY_OK%%CL0%
timeout /t 2 >nul
exit /b 0

:DL_FAIL
echo %CLE%%T_DL_PY_FAIL%%CL0%
pause
exit /b 1

:INSTALL_LIBS
echo %CLR%%T_UPG_PIP%%CL0%
python -m pip install --upgrade pip
echo %CLR%%T_INST_LIB%%CL0%
python -m pip install --upgrade Pillow keyboard
if errorlevel 1 goto :LIB_FAIL
echo %CLD%%T_INST_LIB_OK%%CL0%
timeout /t 2 >nul
exit /b 0

:LIB_FAIL
echo %CLE%%T_INST_LIB_FAIL%%CL0%
pause
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
::  ЯЗЫКОВЫЕ СТРОКИ — РУССКИЙ
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
set "T_LIB_SKIP=[X] БИБЛИОТЕКИ НЕ УСТАНОВЛЕНЫ. ВОЗМОЖНЫ СБОИ."
set "T_GREET=ДОБРО ПОЖАЛОВАТЬ В СИСТЕМУ УПРАВЛЕНИЯ A-123."
set "T_CHECKS_OK=ВСЕ ПРОВЕРКИ ПРОЙДЕНЫ УСПЕШНО."
set "T_READY=СИСТЕМА ГОТОВА К РАБОТЕ."
set "T_PRESS_KEY=НАЖМИТЕ ЛЮБУЮ КЛАВИШУ ДЛЯ ВХОДА В МЕНЮ..."
set "T_STATUS=СТАТУС:"
set "T_CLASS=КЛАССИФИКАЦИЯ: PYTHON."
set "T_RUNNING=РАБОТАЕТ, PID:"
set "T_NOT_RUNNING=НЕ ЗАПУЩЕН"
set "T_NOT_RUNNING_MSG=[X] НЕ ЗАПУЩЕНО."
set "T_MENU_A=[A/1] ЗАПУСТИТЬ"
set "T_MENU_B=[B/2] ОСТАНОВИТЬ"
set "T_MENU_C=[C/3] ПЕРЕЗАПУСТИТЬ"
set "T_MENU_D=[D/4] ПРОВЕРКА БИБЛИОТЕК"
set "T_MENU_E=[E/5] ВЫХОД"
set "T_CHOICE=ВЫБОР: "
set "T_ALREADY_RUN=[X] УЖЕ ЗАПУЩЕНО."
set "T_STARTING=ЗАПУСКАЮ A-123.PY..."
set "T_STARTED=[OK] ЗАПУЩЕНО."
set "T_START_FAIL=[X] СКРИПТ НЕ ЗАПУСТИЛСЯ ЗА 6 СЕК. ПРОВЕРЬТЕ ОШИБКИ."
set "T_STOPPING=ОСТАНАВЛИВАЮ..."
set "T_KILLING=НЕ ОТВЕЧАЕТ, УБИВАЮ ПРИНУДИТЕЛЬНО..."
set "T_STOPPED=[OK] ОСТАНОВЛЕНО."
set "T_DL_PY=СКАЧИВАЮ УСТАНОВЩИК PYTHON..."
set "T_DL_PY_FAIL=[X] НЕ УДАЛОСЬ СКАЧАТЬ PYTHON."
set "T_INST_PY=УСТАНАВЛИВАЮ PYTHON (ТИХАЯ УСТАНОВКА)..."
set "T_INST_PY_OK=[OK] PYTHON УСТАНОВЛЕН."
set "T_UPG_PIP=ОБНОВЛЯЮ PIP..."
set "T_INST_LIB=УСТАНАВЛИВАЮ БИБЛИОТЕКИ (PILLOW, KEYBOARD)..."
set "T_INST_LIB_OK=[OK] БИБЛИОТЕКИ УСТАНОВЛЕНЫ."
set "T_INST_LIB_FAIL=[X] ОШИБКА УСТАНОВКИ БИБЛИОТЕК."
exit /b 0

:: ==================================================
::  ЯЗЫКОВЫЕ СТРОКИ — ENGLISH
:: ==================================================
:LOAD_en
set "T_CHK_PY=[I] CHECKING PYTHON..."
set "T_PY_OK=[OK] PYTHON FOUND."
set "T_PY_NO=[X] PYTHON NOT FOUND."
set "T_ASK_PY=INSTALL PYTHON NOW?"
set "T_YN=(Y/N): "
set "T_PY_REQ=[X] PYTHON IS NOT INSTALLED. THE PROGRAM CANNOT BE STARTED."
set "T_CHK_LIB=[I] CHECKING LIBRARIES..."
set "T_LIB_OK=[OK] ALL LIBRARIES ARE PRESENT."
set "T_LIB_NO=[X] MISSING LIBRARIES: "
set "T_ASK_LIB=INSTALL THEM NOW?"
set "T_LIB_SKIP=[X] LIBRARIES NOT INSTALLED. MAY NOT WORK CORRECTLY."
set "T_GREET=WELCOME TO MANAGEMENT SYSTEM A-123."
set "T_CHECKS_OK=ALL CHECKS PASSED SUCCESSFULLY."
set "T_READY=THE SYSTEM IS READY."
set "T_PRESS_KEY=PRESS ANY KEY TO ENTER THE MENU..."
set "T_STATUS=STATUS:"
set "T_CLASS=CLASSIFICATION: PYTHON."
set "T_RUNNING=RUNNING, PID:"
set "T_NOT_RUNNING=NOT RUNNING"
set "T_NOT_RUNNING_MSG=[X] NOT RUNNING."
set "T_MENU_A=[A/1] START"
set "T_MENU_B=[B/2] STOP"
set "T_MENU_C=[C/3] RESTART"
set "T_MENU_D=[D/4] CHECK LIBRARIES"
set "T_MENU_E=[E/5] EXIT"
set "T_CHOICE=CHOICE: "
set "T_ALREADY_RUN=[X] ALREADY RUNNING."
set "T_STARTING=STARTING A-123.PY..."
set "T_STARTED=[OK] STARTED."
set "T_START_FAIL=[X] SCRIPT DID NOT START IN 6 SEC. CHECK ERRORS."
set "T_STOPPING=STOPPING..."
set "T_KILLING=NOT RESPONDING, FORCE KILLING..."
set "T_STOPPED=[OK] STOPPED."
set "T_DL_PY=DOWNLOADING PYTHON INSTALLER..."
set "T_DL_PY_FAIL=[X] FAILED TO DOWNLOAD PYTHON."
set "T_INST_PY=INSTALLING PYTHON (SILENT)..."
set "T_INST_PY_OK=[OK] PYTHON INSTALLED."
set "T_UPG_PIP=UPGRADING PIP..."
set "T_INST_LIB=INSTALLING LIBRARIES (PILLOW, KEYBOARD)..."
set "T_INST_LIB_OK=[OK] LIBRARIES INSTALLED."
set "T_INST_LIB_FAIL=[X] ERROR INSTALLING LIBRARIES."
exit /b 0
exit /b 0