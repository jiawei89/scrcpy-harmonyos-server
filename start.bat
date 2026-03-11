@echo off
REM ========================================
REM scrcpy for HarmonyOS - One-Click Launcher
REM ========================================

SETLOCAL EnableDelayedExpansion

REM Color settings
set GREEN=[92m
set YELLOW=[93m
set RED=[91m
set RESET=[0m

echo.
echo %GREEN%========================================%RESET%
echo %GREEN%   scrcpy for HarmonyOS 6.0.2+          %RESET%
echo %GREEN%========================================%RESET%
echo.

REM ========================================
REM Step 1: Check required tools
REM ========================================

echo %YELLOW%[1/5] Checking required tools...%RESET%

REM Check hdc
hdc version >nul 2>&1
if errorlevel 1 (
    echo %RED%Error: hdc command not found!%RESET%
    echo.
    echo Please install DevEco Studio and add hdc to PATH
    echo hdc is usually located at: DevEco Studio\tools\hdc\bin
    echo.
    pause
    exit /b 1
)

REM Check device connection
hdc list targets | findstr "offline" >nul 2>&1
if not errorlevel 1 (
    echo %RED%Error: Device is offline! Please check USB connection%RESET%
    pause
    exit /b 1
)

hdc list targets | findstr /C:"Empty" >nul 2>&1
if not errorlevel 1 (
    echo %RED%Error: No device detected! Please connect HarmonyOS device and enable USB debugging%RESET%
    pause
    exit /b 1
)

echo %GREEN%✓ Device connected%RESET%

REM ========================================
REM Step 2: Check server app
REM ========================================

echo.
echo %YELLOW%[2/5] Checking server app...%RESET%

REM Check if HAP file exists
if not exist "scrcpy-server.hap" (
    echo %RED%Error: scrcpy-server.hap not found!%RESET%
    echo.
    echo Please place the compiled HAP file in current directory
    echo File name should be: scrcpy-server.hap
    echo.
    pause
    exit /b 1
)

REM Check if app is installed
hdc shell bm dump -n com.example.scrcpyserver >nul 2>&1
if errorlevel 1 (
    echo %YELLOW%App not installed, installing...%RESET%
    hdc install scrcpy-server.hap

    if errorlevel 1 (
        echo %RED%Installation failed!%RESET%
        pause
        exit /b 1
    )

    echo %GREEN%✓ App installed successfully%RESET%
) else (
    echo %GREEN%✓ App already installed%RESET%
)

REM ========================================
REM Step 3: Check and grant permissions
REM ========================================

echo.
echo %YELLOW%[3/5] Checking permissions...%RESET%

REM Prompt user to manually grant permissions (if needed)
echo.
echo %YELLOW%If device pops up permission request, please click "Allow"%RESET%
echo.
timeout /t 2 /nobreak >nul

REM ========================================
REM Step 4: Start server app
REM ========================================

echo.
echo %YELLOW%[4/5] Starting server app...%RESET%

REM Stop any existing instances first
hdc shell aa force-stop com.example.scrcpyserver >nul 2>&1

REM Start the app
hdc shell aa start -a EntryAbility -b com.example.scrcpyserver >nul 2>&1

if errorlevel 1 (
    echo %RED%Failed to start! Please check device logs%RESET%
    echo.
    echo View logs with:
    echo hdc shell hilog -T ScrcpyServer
    echo.
    pause
    exit /b 1
)

echo %GREEN%✓ Server started%RESET%

REM ========================================
REM Step 5: Start scrcpy client
REM ========================================

echo.
echo %YELLOW%[5/5] Starting scrcpy client...%RESET%
echo.

REM Check scrcpy.exe
if not exist "scrcpy.exe" (
    echo %YELLOW%Note: scrcpy.exe not found, please ensure it's in current directory or PATH%RESET%
    echo.
    echo Download: https://github.com/Genymobile/scrcpy/releases
    echo.
    pause
    exit /b 0
)

REM Start scrcpy
echo %GREEN%Connecting...%RESET%
echo.

scrcpy.exe

REM ========================================
REM Cleanup
REM ========================================

echo.
echo %YELLOW%Disconnecting, stopping server...%RESET%
hdc shell aa force-stop com.example.scrcpyserver >nul 2>&1

echo.
echo %GREEN%Thank you for using!%RESET%
echo.

ENDLOCAL
