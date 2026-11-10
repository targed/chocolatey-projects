$ErrorActionPreference = 'Stop'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://storage.googleapis.com/antigravity-public/antigravity-hub/2.31.0-6379060755038208/windows-x64/Antigravity-x64.exe'
  softwareName   = 'Antigravity*'
  checksum       = 'FA00FD2D97808CF6D280D248FDD707212F18EF3FE282335FB97872FE248AF1B0'
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
