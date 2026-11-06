# Antigravity Package Lifecycle Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Modernize the Antigravity Chocolatey package by adding pre-upgrade process termination, clean NSIS silent switches, a dedicated uninstaller, shortcut cleanup, and nuspec documentation while maintaining full updater compatibility.

**Architecture:** Antigravity is an Electron app packaged with NSIS that installs per-user into `%LOCALAPPDATA%\Programs\antigravity`. Pre-upgrade hooks stop running instances to prevent file locking, `chocolateyinstall.ps1` uses proper `/S /currentuser` flags and fast process shutdown, `chocolateyuninstall.ps1` invokes the NSIS uninstaller from the registry, and `antigravity.nuspec` documents package scope.

**Tech Stack:** Chocolatey, PowerShell 5.1 / Core, NSIS (Nullsoft Scriptable Install System), Nuget.

## Global Constraints
- Preserve the exact `$packageArgs = @{ ... url = ...; checksum = ... }` format in `chocolateyinstall.ps1` for `Chocolatey-Package-Updater.ps1` compatibility.
- Ensure all scripts specify `$ErrorActionPreference = 'Stop'`.
- Use defensive checks (`Test-Path`, `Get-UninstallRegistryKey`) to ensure scripts never throw on missing files or broken prior states.

---

### Task 1: Add `chocolateybeforeModify.ps1`

**Files:**
- Create: `Antigravity/tools/chocolateybeforeModify.ps1`

**Interfaces:**
- Consumes: None
- Produces: Process termination of `antigravity` and `language_server` before upgrades or uninstalls

- [ ] **Step 1: Create `chocolateybeforeModify.ps1`**

```powershell
$ErrorActionPreference = 'Stop'

# Stop Antigravity and its background language server before an upgrade or uninstall so files are not locked
$processes = @('antigravity', 'language_server')
foreach ($proc in $processes) {
  Get-Process -Name $proc -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}

# Wait briefly for file handles in LocalAppData to release
$deadline = (Get-Date).AddSeconds(5)
while ((Get-Date) -lt $deadline -and (Get-Process -Name 'antigravity', 'language_server' -ErrorAction SilentlyContinue)) {
  Start-Sleep -Milliseconds 500
}
```

- [ ] **Step 2: Verify syntax with PowerShell AST parser**

Run:
```powershell
powershell -Command '& { $err = $null; [System.Management.Automation.Language.Parser]::ParseFile("Antigravity/tools/chocolateybeforeModify.ps1", [ref]$null, [ref]$err); if ($err) { throw $err } else { Write-Host "Syntax OK" } }'
```
Expected: `Syntax OK`

- [ ] **Step 3: Commit Task 1**

```bash
git add Antigravity/tools/chocolateybeforeModify.ps1
git commit -m "feat(antigravity): add chocolateybeforeModify.ps1 to release file locks"
```

---

### Task 2: Modernize `chocolateyinstall.ps1`

**Files:**
- Modify: `Antigravity/tools/chocolateyinstall.ps1`

**Interfaces:**
- Consumes: Package parameters, download URL, checksum
- Produces: Clean silent install and fast post-install process termination

- [ ] **Step 1: Update `chocolateyinstall.ps1`**

Replace `Antigravity/tools/chocolateyinstall.ps1` with:

```powershell
$ErrorActionPreference = 'Stop'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://storage.googleapis.com/antigravity-public/antigravity-hub/2.29.0-5723181030440960/windows-x64/Antigravity-x64.exe'
  softwareName   = 'Antigravity*'
  checksum       = '944B109BCB377F9F94F86EEEA7CFA9315D4B42D84FB9D5BAD689058FC11C12BA'
  checksumType   = 'sha256'
  
  # NSIS installer: /S enables silent installation; /currentuser targets the user profile
  silentArgs     = '/S /currentuser'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs

# electron-builder NSIS installers launch the app upon finish; terminate it cleanly without delaying the install
$deadline = (Get-Date).AddSeconds(15)
while ((Get-Date) -lt $deadline) {
  $proc = Get-Process -Name 'antigravity' -ErrorAction SilentlyContinue
  if ($proc) {
    Start-Sleep -Milliseconds 500
    Stop-Process -Name 'antigravity', 'language_server' -Force -ErrorAction SilentlyContinue
    break
  }
  Start-Sleep -Milliseconds 500
}
```

- [ ] **Step 2: Verify syntax with PowerShell AST parser**

Run:
```powershell
powershell -Command '& { $err = $null; [System.Management.Automation.Language.Parser]::ParseFile("Antigravity/tools/chocolateyinstall.ps1", [ref]$null, [ref]$err); if ($err) { throw $err } else { Write-Host "Syntax OK" } }'
```
Expected: `Syntax OK`

- [ ] **Step 3: Commit Task 2**

```bash
git add Antigravity/tools/chocolateyinstall.ps1
git commit -m "fix(antigravity): use NSIS silent switch and fast process termination"
```

---

### Task 3: Create `chocolateyuninstall.ps1`

**Files:**
- Create: `Antigravity/tools/chocolateyuninstall.ps1`

**Interfaces:**
- Consumes: Registry uninstall string, install path
- Produces: Complete uninstallation of Antigravity and removal of shortcuts and folders

- [ ] **Step 1: Create `chocolateyuninstall.ps1`**

```powershell
$ErrorActionPreference = 'Stop'

# Stop active Antigravity processes
Get-Process -Name 'antigravity', 'language_server' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# Query registry for the NSIS uninstaller
[array]$key = Get-UninstallRegistryKey -SoftwareName 'Antigravity*' |
  Where-Object { $_.UninstallString -match 'Uninstall Antigravity\.exe' }

if ($key.Count -ge 1) {
  # UninstallString looks like: "C:\...\Uninstall Antigravity.exe" /currentuser
  $file = $key[0].UninstallString -replace '\s*/\S+.*$', '' -replace '^"(.*)"$', '$1'
  if (Test-Path $file) {
    Uninstall-ChocolateyPackage -PackageName $env:ChocolateyPackageName `
      -FileType 'exe' `
      -SilentArgs '/currentuser /S' `
      -ValidExitCodes @(0) `
      -File $file
  }
}

# Remove Desktop and Start Menu shortcuts
$shortcuts = @(
  "$env:USERPROFILE\Desktop\Antigravity.lnk",
  (Join-Path ([Environment]::GetFolderPath('Programs')) 'Antigravity.lnk'),
  (Join-Path ([Environment]::GetFolderPath('Programs')) 'Google\Antigravity.lnk')
)
foreach ($shortcut in $shortcuts) {
  if (Test-Path $shortcut) {
    Remove-Item -Path $shortcut -Force -ErrorAction SilentlyContinue
  }
}

# Fallback cleanup of local install folder if any files remain
$localAppData = [Environment]::GetFolderPath('LocalApplicationData')
if (-not [string]::IsNullOrWhiteSpace($localAppData)) {
  $installDir = Join-Path $localAppData 'Programs\antigravity'
  if (Test-Path $installDir) {
    Remove-Item -Path $installDir -Recurse -Force -ErrorAction SilentlyContinue
  }
}

# Remove package tools directory only if it is inside the Chocolatey lib folder
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
if (-not [string]::IsNullOrWhiteSpace($env:ChocolateyInstall) -and -not [string]::IsNullOrWhiteSpace($toolsDir)) {
  $resolvedTools = [System.IO.Path]::GetFullPath($toolsDir)
  $chocoLibDir = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($env:ChocolateyInstall, 'lib'))
  $expectedLibPrefix = $chocoLibDir.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
  if ($resolvedTools.StartsWith($expectedLibPrefix, [System.StringComparison]::OrdinalIgnoreCase) -and (Test-Path $resolvedTools)) {
    Remove-Item $resolvedTools -Recurse -Force -ErrorAction SilentlyContinue
  }
}
```

- [ ] **Step 2: Verify syntax with PowerShell AST parser**

Run:
```powershell
powershell -Command '& { $err = $null; [System.Management.Automation.Language.Parser]::ParseFile("Antigravity/tools/chocolateyuninstall.ps1", [ref]$null, [ref]$err); if ($err) { throw $err } else { Write-Host "Syntax OK" } }'
```
Expected: `Syntax OK`

- [ ] **Step 3: Commit Task 3**

```bash
git add Antigravity/tools/chocolateyuninstall.ps1
git commit -m "feat(antigravity): add chocolateyuninstall.ps1 for clean uninstallation"
```

---

### Task 4: Update `antigravity.nuspec`

**Files:**
- Modify: `Antigravity/antigravity.nuspec`

**Interfaces:**
- Consumes: Package metadata
- Produces: Clear description including package installation notes

- [ ] **Step 1: Add Package Notes to `antigravity.nuspec`**

In `Antigravity/antigravity.nuspec`, append package notes inside `<description>`:

```xml
## Package Notes

This package installs Google Antigravity per-user into `%LOCALAPPDATA%\Programs\antigravity`.
```

- [ ] **Step 2: Commit Task 4**

```bash
git add Antigravity/antigravity.nuspec
git commit -m "docs(antigravity): document per-user install scope in nuspec"
```

---

### Task 5: End-to-End Verification

**Files:**
- `Antigravity/tools/*`
- `Antigravity/antigravity.nuspec`
- `Antigravity/updateNew.ps1`

- [ ] **Step 1: Run AST parser check on all package scripts**

Run:
```powershell
powershell -Command '& {
  $files = @("Antigravity/tools/chocolateybeforeModify.ps1", "Antigravity/tools/chocolateyinstall.ps1", "Antigravity/tools/chocolateyuninstall.ps1", "Antigravity/updateNew.ps1")
  foreach ($f in $files) {
    $err = $null
    [System.Management.Automation.Language.Parser]::ParseFile($f, [ref]$null, [ref]$err)
    if ($err) { throw "$f has syntax error: $err" } else { Write-Host "$f : Syntax OK" }
  }
}'
```
Expected: All 4 scripts report `Syntax OK`.

- [ ] **Step 2: Build the package using `choco pack`**

Run:
```powershell
choco pack Antigravity/antigravity.nuspec --outputdirectory Antigravity
```
Expected: Exit code 0, successfully created `Antigravity\antigravity.2.29.0.nupkg`.

- [ ] **Step 3: Test regex pattern matching against `chocolateyinstall.ps1`**

Run:
```powershell
powershell -Command '& {
  $content = Get-Content "Antigravity/tools/chocolateyinstall.ps1" -Raw
  $urlMatch = [regex]::Match($content, "(?i)(?<=(url\s*=\s*)[`"'"'"'])(.*?)(?=[`"'"'"'])")
  $checksumMatch = [regex]::Match($content, "(?i)(?<=(checksum\s*=\s*)[`"'"'"'])(.*?)(?=[`"'"'"'])")
  Write-Host "URL match: $($urlMatch.Success) -> $($urlMatch.Value)"
  Write-Host "Checksum match: $($checksumMatch.Success) -> $($checksumMatch.Value)"
  if (-not $urlMatch.Success -or -not $checksumMatch.Success) { throw "Regex matching failed" }
}'
```
Expected: Both matches return `True` with valid values.
