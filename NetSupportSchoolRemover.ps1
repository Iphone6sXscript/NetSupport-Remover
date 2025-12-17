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

# Function to auto-find NetSupport folders and list contents
function Auto-FindNetSupport {
    Write-Host "Choose scan locations:" -ForegroundColor Cyan
    Write-Host "1. Program Files"
    Write-Host "2. Program Files (x86)"
    Write-Host "3. AppData"
    Write-Host "4. All"
    $locationChoice = Read-Host "Enter your choice (1-4)"

    $scanPaths = @()
    switch ($locationChoice) {
        1 { $scanPaths = @($env:ProgramFiles) }
        2 { $scanPaths = @("${env:ProgramFiles(x86)}") }
        3 { $scanPaths = @($env:APPDATA) }
        4 { $scanPaths = @($env:ProgramFiles, "${env:ProgramFiles(x86)}", $env:APPDATA) }
        default { Write-Host "Invalid choice. Scanning all by default." -ForegroundColor Yellow; $scanPaths = @($env:ProgramFiles, "${env:ProgramFiles(x86)}", $env:APPDATA) }
    }

    $foundFolders = @()
    Write-Host "Scanning selected locations for folders named 'NetSupport'... This may take a moment." -ForegroundColor Cyan
    foreach ($scanPath in $scanPaths) {
        if (Test-Path $scanPath) {
            $netsupportFolders = Get-ChildItem -Path $scanPath -Directory -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq "NetSupport" }
            foreach ($folder in $netsupportFolders) {
                $foundFolders += $folder.FullName
            }
        }
    }

    if ($foundFolders.Count -eq 0) {
        Write-Host "No folders named 'NetSupport' found in selected locations." -ForegroundColor Yellow
        return
    }

    Write-Host "Found NetSupport folders:" -ForegroundColor Green
    $i = 1
    foreach ($folder in $foundFolders) {
        Write-Host "$i. $folder"
        # List contents (subfolders and files, up to 10 items for brevity)
        $contents = Get-ChildItem -Path $folder -ErrorAction SilentlyContinue
        $subfolders = $contents | Where-Object { $_.PSIsContainer }
        $files = $contents | Where-Object { -not $_.PSIsContainer }
        if ($subfolders) {
            Write-Host "  Subfolders:"
            $subfolders | Select-Object -First 5 | ForEach-Object { Write-Host "    - $($_.Name)" }
            if ($subfolders.Count -gt 5) { Write-Host "    ... and $($subfolders.Count - 5) more subfolders" }
        }
        if ($files) {
            Write-Host "  Files:"
            $files | Select-Object -First 5 | ForEach-Object { Write-Host "    - $($_.Name)" }
            if ($files.Count -gt 5) { Write-Host "    ... and $($files.Count - 5) more files" }
        }
        $i++
    }

    Write-Host ""
    $choice = Read-Host "Enter the number of the folder to remove (or '0' to cancel)"
    if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $foundFolders.Count) {
        $selectedPath = $foundFolders[[int]$choice - 1]
        Write-Host "Confirm removal of: $selectedPath and all contents? (y/n): " -NoNewline
        $confirm = Read-Host
        if ($confirm -eq 'y') {
            try {
                Remove-Item -Path $selectedPath -Recurse -Force
                Write-Host "Removed: $selectedPath" -ForegroundColor Green
            } catch {
                Write-Host "Failed to remove: $selectedPath ($_.Exception.Message)" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "Cancelled or invalid choice." -ForegroundColor Yellow
    }
}

# Main menu loop
do {
    Clear-Host
    Write-Host "NetSupport School Remover Menu" -ForegroundColor Magenta
    Write-Host "1. List NetSupport School Folders/Files"
    Write-Host "2. Remove All NetSupport School Folders/Files"
    Write-Host "3. Remove Specific Folder/File"
    Write-Host "4. Auto-Find NetSupport Folders and List Contents"
    Write-Host "5. Exit"
    Write-Host ""
    $choice = Read-Host "Choose an option (1-5)"

    switch ($choice) {
        1 { List-Folders; Read-Host "Press Enter to continue" }
        2 { Remove-AllFolders; Read-Host "Press Enter to continue" }
        3 { Remove-Specific; Read-Host "Press Enter to continue" }
        4 { Auto-FindNetSupport; Read-Host "Press Enter to continue" }
        5 { Write-Host "Exiting..." }
        default { Write-Host "Invalid choice. Try again." -ForegroundColor Red; Read-Host "Press Enter to continue" }
    }
} while ($choice -ne 5)