@echo off
echo ========================================================
echo   Compiling Othrys Windows Release & Installer Setup
echo ========================================================

cd /d %~dp0vpsmanager
echo [1/3] Building Flutter Windows Release...
call flutter build windows --release
if %ERRORLEVEL% NEQ 0 (
    echo Error during flutter build.
    exit /b %ERRORLEVEL%
)

echo [2/4] Preparing and signing binaries...
copy /y build\windows\x64\runner\Release\vpsmanager.exe build\windows\x64\runner\Release\othrys.exe >nul
powershell -ExecutionPolicy Bypass -File "%~dp0sign_binaries.ps1"

echo [3/4] Building Inno Setup Installer...
set ISCC=%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe
if not exist %ISCC% set ISCC=C:\Program Files (x86)\Inno Setup 6\ISCC.exe
if not exist %ISCC% set ISCC=C:\Program Files\Inno Setup 6\ISCC.exe

%ISCC% installer.iss
if %ERRORLEVEL% NEQ 0 (
    echo Error during Inno Setup compilation.
    exit /b %ERRORLEVEL%
)

for %%f in ("%~dp0dist\Othrys-Setup-*.exe") do copy /y "%%f" "%~dp0dist\Othrys-Setup.exe" >nul

echo [4/4] Signing final installer...
powershell -ExecutionPolicy Bypass -File "%~dp0sign_binaries.ps1"

echo.
echo ========================================================
echo   Success! Signed installer created at:
echo   %~dp0dist\Othrys-Setup.exe
echo ========================================================
