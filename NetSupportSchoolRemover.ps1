# NetSupport School Remover
# Run as Administrator. Use at your own risk.

# ==============================
# Admin Check
# ==============================
function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Administrator rights required. Relaunching..." -ForegroundColor Red
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
}
Test-Admin

# ==============================
# NetSupport Paths
# ==============================
function Get-NetSupportPaths {
    $pf = $env:ProgramFiles
    $pfx86 = ${env:ProgramFiles(x86)}
    $appdata = $env:APPDATA
    $user = $env:USERPROFILE

    return @(
        "$pf\NetSupport",
        "$pfx86\NetSupport",
        "$pf\NetSupport\NetSupport School",
        "$pfx86\NetSupport\NetSupport School",
        "$appdata\NetSupport",
        "$user\Documents\Journals",
        "$user\Documents\My Recordings",
        "$pf\NetSupport\NetSupport School\client32u.ini",
        "$pfx86\NetSupport\NetSupport School\client32u.ini"
    )
}

$NetSupportPaths = Get-NetSupportPaths

# ==============================
# Target Processes
# ==============================
$TargetProcesses = @(
    "client32",
    "RevitAccelerator",
    "Runplugin64",
    "runplugin",
    "node",
    "msedge",
    "smartscreen",
    "CollaborationKeysController"
)

# ==============================
# List Paths
# ==============================
function List-NetSupport {
    Clear-Host
    Write-Host "NetSupport Locations:" -ForegroundColor Cyan
    foreach ($p in $NetSupportPaths) {
        if (Test-Path $p) {
            Write-Host "[FOUND] $p" -ForegroundColor Green
        } else {
            Write-Host "[NOT FOUND] $p" -ForegroundColor Yellow
        }
    }
    Pause
}

# ==============================
# Remove All
# ==============================
function Remove-AllNetSupport {
    Clear-Host
    Write-Host "WARNING: This will delete ALL NetSupport data!" -ForegroundColor Red
    $c = Read-Host "Type Y to continue"
    if ($c -ne "Y") { return }

    foreach ($p in $NetSupportPaths) {
        if (Test-Path $p) {
            try {
                Remove-Item $p -Recurse -Force -ErrorAction Stop
                Write-Host "Removed: $p" -ForegroundColor Green
            } catch {
                Write-Host "Failed: $p" -ForegroundColor Red
            }
        }
    }
    Pause
}

# ==============================
# Remove Specific
# ==============================
function Remove-Specific {
    Clear-Host
    $i = 1
    foreach ($p in $NetSupportPaths) {
        Write-Host "$i. $p"
        $i++
    }
    $choice = Read-Host "Choose number"
    if ($choice -match '^\d+$' -and $choice -le $NetSupportPaths.Count) {
        $path = $NetSupportPaths[$choice - 1]
        if (Test-Path $path) {
            Remove-Item $path -Recurse -Force
            Write-Host "Removed: $path" -ForegroundColor Green
        }
    }
    Pause
}

# ==============================
# AUTO SCAN
# ==============================
function Auto-ScanNetSupport {
    Clear-Host
    Write-Host "AUTO SCAN RESULTS" -ForegroundColor Cyan

    Write-Host "`n[FOLDERS]" -ForegroundColor White
    foreach ($p in $NetSupportPaths) {
        if (Test-Path $p) {
            Write-Host "FOUND: $p" -ForegroundColor Green
        }
    }

    Write-Host "`n[PROCESSES]" -ForegroundColor White
    foreach ($proc in $TargetProcesses) {
        if (Get-Process -Name $proc -ErrorAction SilentlyContinue) {
            Write-Host "RUNNING: $proc.exe" -ForegroundColor Green
        }
    }

    Write-Host "`n[SERVICES]" -ForegroundColor White
    $svc = Get-Service | Where-Object {
        $_.Name -match "NetSupport" -or $_.DisplayName -match "NetSupport"
    }
    if ($svc) {
        $svc | ForEach-Object {
            Write-Host "FOUND: $($_.Name) ($($_.Status))" -ForegroundColor Green
        }
    } else {
        Write-Host "No NetSupport services found."
    }

    Pause
}

# ==============================
# Kill Tasks
# ==============================
function Kill-NetSupportTasks {
    Clear-Host
    Write-Host "Killing selected processes..." -ForegroundColor Red

    foreach ($proc in $TargetProcesses) {
        $p = Get-Process -Name $proc -ErrorAction SilentlyContinue
        if ($p) {
            Stop-Process -Name $proc -Force
            Write-Host "Killed: $proc.exe" -ForegroundColor Green
        } else {
            Write-Host "Not running: $proc.exe" -ForegroundColor Yellow
        }
    }
    Pause
}

# ==============================
# AUTO REMOVE MODE
# ==============================
if ($AutoRemove) {
    Write-Host "AUTO REMOVE MODE: Removing all NetSupport components..." -ForegroundColor Red
    Kill-NetSupportTasks
    foreach ($p in $NetSupportPaths) {
        if (Test-Path $p) {
            try {
                Remove-Item $p -Recurse -Force -ErrorAction Stop
                Write-Host "Removed: $p" -ForegroundColor Green
            } catch {
                Write-Host "Failed: $p" -ForegroundColor Red
            }
        }
    }
    Write-Host "Auto removal complete. Exiting..." -ForegroundColor Green
    exit
}

# ==============================
# MENU
# ==============================
do {
    Clear-Host
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " NetSupport School Remover v2" -ForegroundColor White
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "1. List NetSupport folders/files"
    Write-Host "2. Remove ALL NetSupport data"
    Write-Host "3. Remove specific folder/file"
    Write-Host "4. AUTO SCAN NetSupport"
    Write-Host "5. Kill NetSupport-related tasks"
    Write-Host "6. Exit"
    Write-Host "========================================" -ForegroundColor Cyan

    $choice = Read-Host "Choose (1-6)"

    switch ($choice) {
        1 { List-NetSupport }
        2 { Remove-AllNetSupport }
        3 { Remove-Specific }
        4 { Auto-ScanNetSupport }
        5 { Kill-NetSupportTasks }
        6 { break }
    }
} while ($true)
