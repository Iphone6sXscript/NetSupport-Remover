# USB Autorun Setup Guide

## How to Use (Zero-Day USB Execution)

### For Windows 7 and Earlier (Autorun Enabled by Default)
1. Copy all files to USB root directory
2. Plug USB into target computer
3. Autorun will automatically execute `RunRemover.bat`
4. Grant admin privileges when prompted

### For Windows 8/10/11 (Autorun Disabled by Default)

#### Method 1: Manual Double-Click
1. Copy all files to USB root directory
2. Plug USB into target computer
3. Open USB drive in Explorer
4. Double-click `RunRemover.bat`
5. Grant admin privileges when prompted

#### Method 2: Enable Autorun via Registry (Requires Admin)
Run this command as Administrator before plugging USB:
```cmd
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDriveTypeAutoRun /t REG_DWORD /d 0x91 /f
```

#### Method 3: Use AutoRun.exe Launcher (Alternative)
Create a simple launcher that users can click:
- Rename `RunRemover.bat` to something innocuous like `Setup.bat` or `Install.bat`
- Users will naturally click it when they see it

## Files Required on USB
```
USB_ROOT/
├── autorun.inf
├── RunRemover.bat
└── NetSupportSchoolRemover.ps1
```

## How It Works
1. **autorun.inf** - Tells Windows to execute RunRemover.bat when USB is inserted
2. **RunRemover.bat** - Checks for admin rights and launches PowerShell script
3. **NetSupportSchoolRemover.ps1** - Main removal tool with menu interface

## Important Notes
- Modern Windows (8+) has autorun disabled for security
- User must manually run the batch file on modern systems
- Admin privileges are required for full functionality
- The batch file uses `%~dp0` to work from any drive letter

## Security Considerations
⚠️ **Legal Warning**: Only use on systems you own or have explicit permission to modify.
Unauthorized use may violate computer fraud laws.

## Troubleshooting
- If autorun doesn't work: Manually double-click `RunRemover.bat`
- If PowerShell script blocked: Run as Administrator
- If execution policy error: The batch file handles this automatically
