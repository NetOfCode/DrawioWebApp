@echo off
REM ============================================================================
REM Automated IIS Setup Script for Draw.io Web Application
REM Run this as Administrator
REM ============================================================================

echo.
echo ========================================================================
echo    Draw.io Web Application - IIS Setup Script
echo ========================================================================
echo.

REM Check for administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script must be run as Administrator!
    echo Right-click this file and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo Checking IIS installation...
%windir%\system32\inetsrv\appcmd.exe list sites >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: IIS is not installed or not accessible!
    echo Please install IIS first through Windows Features.
    echo.
    pause
    exit /b 1
)

echo IIS is installed.
echo.

REM Get current directory
set APP_PATH=%~dp0
set APP_PATH=%APP_PATH:~0,-1%

echo Application path: %APP_PATH%
echo.

echo Creating IIS Application...
%windir%\system32\inetsrv\appcmd.exe add app /site.name:"Default Web Site" /path:/DrawioWebApp /physicalPath:"%APP_PATH%" >nul 2>&1
if %errorLevel% equ 0 (
    echo SUCCESS: IIS Application created successfully!
) else (
    echo Application may already exist or there was an error.
    echo Attempting to update existing application...
    %windir%\system32\inetsrv\appcmd.exe set app "Default Web Site/DrawioWebApp" /physicalPath:"%APP_PATH%"
)

echo.
echo Setting permissions...
icacls "%APP_PATH%" /grant "IIS AppPool\DefaultAppPool:(OI)(CI)RX" /T >nul 2>&1
if %errorLevel% equ 0 (
    echo SUCCESS: Permissions set successfully!
) else (
    echo WARNING: Could not set permissions automatically.
    echo You may need to set them manually in IIS Manager.
)

echo.
echo Ensuring Default.aspx is a default document...
%windir%\system32\inetsrv\appcmd.exe set config "Default Web Site/DrawioWebApp" /section:defaultDocument /+files.[value='Default.aspx'] >nul 2>&1

echo.
echo Recycling application pool...
%windir%\system32\inetsrv\appcmd.exe recycle apppool "DefaultAppPool" >nul 2>&1

echo.
echo ========================================================================
echo    Setup Complete!
echo ========================================================================
echo.
echo The application should now be accessible at:
echo    http://localhost/DrawioWebApp
echo.
echo Opening in your default browser...
echo.

REM Wait 2 seconds for IIS to process
timeout /t 2 /nobreak >nul 2>&1

REM Open browser
start http://localhost/DrawioWebApp

echo.
echo If the page doesn't load, please check:
echo  1. IIS is running (services.msc → World Wide Web Publishing Service)
echo  2. .NET Framework 4.7.2 or higher is installed
echo  3. ASP.NET 4.x is enabled in IIS
echo.
echo For troubleshooting, see SETUP_GUIDE.txt
echo.
pause

