# Antigravity Package Lifecycle Design

## Goal
Improve the Google Antigravity Chocolatey package to full lifecycle parity with modern package standards: clean NSIS silent arguments, safe pre-upgrade process termination, a dedicated uninstaller, shortcut cleanup, and seamless compatibility with the automated updater.

## Background & Architecture
Antigravity is an Electron application distributed via Google Cloud Storage and packaged as an NSIS (`electron-builder`) installer. It installs per-user into `%LOCALAPPDATA%\Programs\antigravity`.

Currently, the Chocolatey package:
1. Passes an invalid mix of Inno/MSI flags in `silentArgs`.
2. Runs a 60-second wait-and-kill loop with a 10-second sleep after installation.
3. Completely lacks a `chocolateyuninstall.ps1` script, leaving files and registry entries orphaned on uninstall.
4. Completely lacks a `chocolateybeforeModify.ps1` script, risking file locks on `Antigravity.exe` and `language_server.exe` during upgrades.

### Components

#### 1. `Antigravity/tools/chocolateybeforeModify.ps1`
Runs before upgrades and uninstalls.
- Terminates running `antigravity` and `language_server` processes using `Stop-Process -Force -ErrorAction SilentlyContinue`.
- Waits up to 5 seconds for file handles in `%LOCALAPPDATA%\Programs\antigravity` to release.

#### 2. `Antigravity/tools/chocolateyinstall.ps1`
- Sets `$ErrorActionPreference = 'Stop'`.
- Sets `silentArgs = '/S /currentuser'` (standard NSIS silent switch).
- Preserves the exact `$packageArgs = @{ ... url = '...'; checksum = '...' }` hash table structure so `Chocolatey-Package-Updater.ps1` and `updateNew.ps1` continue working.
- Replaces the 60s wait loop and 10s sleep with a fast, targeted 15-second loop that stops `antigravity.exe` immediately when it appears, exiting as soon as the process is stopped.

#### 3. `Antigravity/tools/chocolateyuninstall.ps1`
- Sets `$ErrorActionPreference = 'Stop'`.
- Stops active processes (`antigravity`, `language_server`).
- Queries `Get-UninstallRegistryKey -SoftwareName 'Antigravity*'` to locate `Uninstall Antigravity.exe`.
- Checks `Test-Path $file` defensively before calling `Uninstall-ChocolateyPackage -PackageName $env:ChocolateyPackageName -FileType 'exe' -SilentArgs '/currentuser /S' -ValidExitCodes @(0) -File $file`.
- Removes shortcuts:
  - `$env:USERPROFILE\Desktop\Antigravity.lnk`
  - `Join-Path ([Environment]::GetFolderPath('Programs')) 'Antigravity.lnk'`
- Removes fallback directory `%LOCALAPPDATA%\Programs\antigravity` if files remain.
- Removes package tools directory from Chocolatey lib.

#### 4. `Antigravity/antigravity.nuspec`
- Adds a `## Package Notes` section documenting that Antigravity installs per-user into `%LOCALAPPDATA%\Programs\antigravity`.

## Verification Plan
1. **PowerShell AST Syntax Verification**: Verify all PowerShell scripts parse with zero syntax errors.
2. **Package Build**: Run `choco pack Antigravity/antigravity.nuspec --outputdirectory Antigravity` and ensure exit code 0.
3. **Updater Compatibility**: Verify `Chocolatey-Package-Updater.ps1` regex matching against the modified `chocolateyinstall.ps1`.
