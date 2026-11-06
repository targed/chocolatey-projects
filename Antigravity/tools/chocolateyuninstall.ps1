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
