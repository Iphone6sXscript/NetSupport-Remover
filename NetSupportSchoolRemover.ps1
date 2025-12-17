# NetSupport School Remover with Menu UI
# Run as Administrator. Use at your own risk.

# Function to check for admin rights
function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "This script requires administrator privileges. Relaunching as admin..." -ForegroundColor Red
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
}

# Call admin check
Test-Admin

# Function to get folder paths based on system
function Get-NetSupportPaths {
    $is64Bit = [Environment]::Is64BitOperatingSystem
    $programFiles = if ($is64Bit) { "${env:ProgramFiles(x86)}" } else { $env:ProgramFiles }
    $appData = $env:APPDATA
    $userProfile = $env:USERPROFILE

    return @{
        TutorReports = "$programFiles\NetSupport\NetSupport School\Reports"
        TutorTests = "$programFiles\NetSupport\NetSupport School\Tests"
        ClassLists = "$appData\NetSupport\NetSupport School"
        Journals = "$userProfile\Documents\Journals"
        Recordings = "$userProfile\Documents\My Recordings"
        StudentConfig = "$programFiles\NetSupport\NetSupport School\client32u.ini"
        TechClassLists = "$appData\NetSupport\NetSupport School"  # Same as Tutor Class Lists
    }
}

# Function to list folders
function List-Folders {
    $paths = Get-NetSupportPaths
    Write-Host "NetSupport School Folder/File Locations:" -ForegroundColor Cyan
    foreach ($key in $paths.Keys) {
        $path = $paths[$key]
        if (Test-Path $path) {
            Write-Host "$key : $path (Exists)" -ForegroundColor Green
        } else {
            Write-Host "Cannot find folder/file: $path" -ForegroundColor Yellow
        }
    }
}

# Function to remove all folders/files
function Remove-AllFolders {
    $paths = Get-NetSupportPaths
    Write-Host "This will delete ALL listed folders/files (if they exist). Confirm? (y/n): " -NoNewline
    $confirm = Read-Host
    if ($confirm -ne 'y') { return }

    foreach ($key in $paths.Keys) {
        $path = $paths[$key]
        if (Test-Path $path) {
            try {
                if ($key -eq 'StudentConfig') {
                    Remove-Item -Path $path -Force  # File removal
                } else {
                    Remove-Item -Path $path -Recurse -Force  # Folder removal
                }
                Write-Host "Removed: $path" -ForegroundColor Green
            } catch {
                Write-Host "Failed to remove: $path ($_.Exception.Message)" -ForegroundColor Red
            }
        } else {
            Write-Host "Cannot find folder/file: $path" -ForegroundColor Yellow
        }
    }
    Write-Host "Removal complete. Reboot recommended for full effect."
}

# Function to remove specific folder/file
function Remove-Specific {
    $paths = Get-NetSupportPaths
    Write-Host "Available options to remove:" -ForegroundColor Cyan
    $i = 1
    foreach ($key in $paths.Keys) {
        Write-Host "$i. $key : $($paths[$key])"
        $i++
    }
    Write-Host "$i. Custom path (enter your own)"
    Write-Host ""
    $choice = Read-Host "Choose a number or enter custom path"
    
    if ($choice -match '^\d+$' -and [int]$choice -le $paths.Count) {
        $selectedKey = $paths.Keys[[int]$choice - 1]
        $path = $paths[$selectedKey]
    } elseif ($choice -eq $i) {
        $path = Read-Host "Enter custom path"
    } else {
        Write-Host "Invalid choice." -ForegroundColor Red
        return
    }
    
    if (Test-Path $path) {
        Write-Host "Confirm removal of: $path (y/n): " -NoNewline
        $confirm = Read-Host
        if ($confirm -eq 'y') {
            try {
                if (Test-Path $path -PathType Leaf) {
                    Remove-Item -Path $path -Force  # File
                } else {
                    Remove-Item -Path $path -Recurse -Force  # Folder
                }
                Write-Host "Removed: $path" -ForegroundColor Green
            } catch {
                Write-Host "Failed to remove: $path ($_.Exception.Message)" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "Cannot find folder/file: $path" -ForegroundColor Yellow
    }
}

# Main menu loop
do {
    Clear-Host
    Write-Host "NetSupport School Remover Menu" -ForegroundColor Magenta
    Write-Host "1. List NetSupport School Folders/Files"
    Write-Host "2. Remove All NetSupport School Folders/Files"
    Write-Host "3. Remove Specific Folder/File"
    Write-Host "4. Exit"
    Write-Host ""
    $choice = Read-Host "Choose an option (1-4)"

    switch ($choice) {
        1 { List-Folders; Read-Host "Press Enter to continue" }
        2 { Remove-AllFolders; Read-Host "Press Enter to continue" }
        3 { Remove-Specific; Read-Host "Press Enter to continue" }
        4 { Write-Host "Exiting..." }
        default { Write-Host "Invalid choice. Try again." -ForegroundColor Red; Read-Host "Press Enter to continue" }
    }
} while ($choice -ne 4)