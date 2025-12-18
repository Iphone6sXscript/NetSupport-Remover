@echo off
echo Checking for admin rights...
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running as admin.
) else (
    echo Requesting admin rights...
    powershell "start-process '%~f0' -verb runas"
    exit /b
)

echo Setting execution policy and running NetSupport Remover...
powershell -ExecutionPolicy Bypass -File "F:\NetSupportSchoolRemover.ps1"

pause