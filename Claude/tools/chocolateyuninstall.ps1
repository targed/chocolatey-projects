$ErrorActionPreference = 'Stop'

Get-Process -Name 'claude' -ErrorAction SilentlyContinue | Stop-Process -Force

# Run the Squirrel uninstaller first, so the Add/Remove Programs and Start menu entries are removed.
# It lives inside the folder that the cleanup below deletes.
[array]$key = Get-UninstallRegistryKey -SoftwareName 'Claude*' |
  Where-Object { $_.UninstallString -match 'Update\.exe' }
if ($key.Count -eq 1) {
  # UninstallString looks like: "C:\...\Update.exe" --uninstall
  $file = $key[0].UninstallString -replace '\s*--\S+.*$', '' -replace '^"(.*)"$', '$1'
  Uninstall-ChocolateyPackage -PackageName $env:ChocolateyPackageName `
    -FileType 'exe' `
    -SilentArgs '--uninstall' `
    -ValidExitCodes @(0) `
    -File $file
} elseif ($key.Count -gt 1) {
  Write-Warning "$($key.Count) Squirrel uninstall entries found for 'Claude*' - skipping the uninstaller."
}

$folderName = "AnthropicClaude"

# Validate $folderName strictly: must be non-empty alphanumeric with optional underscores or dashes
if ([string]::IsNullOrWhiteSpace($folderName) -or $folderName -notmatch '^[a-zA-Z0-9_\-]+$') {
    throw "Invalid folder name specified: '$folderName'"
}

$shortcutPath = "$env:USERPROFILE\Desktop\Claude.lnk"

# Remove the extracted files from Chocolatey lib directory
if (-not [string]::IsNullOrWhiteSpace($env:ChocolateyInstall)) {
    $chocoLibDir = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($env:ChocolateyInstall, "lib"))
    $unzipLocation = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($chocoLibDir, $folderName))

    # Ensure $unzipLocation is strictly a child directory inside $chocoLibDir and matches $folderName
    $expectedLibPrefix = $chocoLibDir.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    if ($unzipLocation.StartsWith($expectedLibPrefix, [System.StringComparison]::OrdinalIgnoreCase) -and 
        (Split-Path -Leaf $unzipLocation) -eq $folderName -and 
        (Test-Path $unzipLocation)) {
        Remove-Item $unzipLocation -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Remove Claude directory in old location if it exists (AppData/Local/AnthropicClaude)
$localAppData = [Environment]::GetFolderPath("LocalApplicationData")
if (-not [string]::IsNullOrWhiteSpace($localAppData)) {
    $localAppDataDir = [System.IO.Path]::GetFullPath($localAppData)
    $oldUnzipLocation = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($localAppDataDir, $folderName))

    # Ensure $oldUnzipLocation is strictly a child directory inside $localAppData and matches $folderName
    $expectedLocalAppPrefix = $localAppDataDir.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    if ($oldUnzipLocation.StartsWith($expectedLocalAppPrefix, [System.StringComparison]::OrdinalIgnoreCase) -and 
        (Split-Path -Leaf $oldUnzipLocation) -eq $folderName -and 
        (Test-Path $oldUnzipLocation)) {
        Remove-Item -Path $oldUnzipLocation -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Remove the desktop shortcut
if (-not [string]::IsNullOrWhiteSpace($shortcutPath) -and $shortcutPath.EndsWith('.lnk') -and (Test-Path $shortcutPath)) {
    Remove-Item $shortcutPath -Force
}

# Claude creates this Start menu shortcut itself on first run, and the Squirrel uninstaller leaves it behind
$startMenuShortcut = Join-Path ([Environment]::GetFolderPath('Programs')) 'Claude.lnk'
if (Test-Path $startMenuShortcut) {
    Remove-Item $startMenuShortcut -Force
}

# Remove package tools directory only if it is inside the Chocolatey lib folder
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
if (-not [string]::IsNullOrWhiteSpace($env:ChocolateyInstall) -and -not [string]::IsNullOrWhiteSpace($toolsDir)) {
    $resolvedTools = [System.IO.Path]::GetFullPath($toolsDir)
    $chocoLibDir = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($env:ChocolateyInstall, "lib"))
    $expectedLibPrefix = $chocoLibDir.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    if ($resolvedTools.StartsWith($expectedLibPrefix, [System.StringComparison]::OrdinalIgnoreCase) -and (Test-Path $resolvedTools)) {
        Remove-Item $resolvedTools -Recurse -Force -ErrorAction SilentlyContinue
    }
}
