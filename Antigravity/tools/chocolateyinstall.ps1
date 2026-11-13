$ErrorActionPreference = 'Stop'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://storage.googleapis.com/antigravity-public/antigravity-hub/2.31.2-6470801290035200/windows-x64/Antigravity-x64.exe'
  softwareName   = 'Antigravity*'
  checksum       = 'C8C5112E2E6FEC74220A7FF016BD19BB3FA6E08D44438DCB14B5ECC23FFA2BA0'
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
