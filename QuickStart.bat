@echo off
title NetSupport School Remover - Quick Start
color 0A

echo.
echo ========================================
echo  NetSupport School Remover
echo  Quick Start Launcher
echo ========================================
echo.
echo This tool will remove NetSupport School
echo from your computer.
echo.
echo Press any key to continue...
pause >nul

echo.
echo Launching with administrator privileges...
powershell -Command "Start-Process '%~dp0RunRemover.bat' -Verb RunAs"

exit
