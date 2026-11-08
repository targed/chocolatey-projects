$ErrorActionPreference = 'Stop'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://storage.googleapis.com/antigravity-public/antigravity-hub/2.29.1-5241471524274176/windows-x64/Antigravity-x64.exe'
  softwareName   = 'Antigravity*'
  checksum       = 'A842B73218CB35E029E8425A28C79A388280E03D389C50FD93FF75AF1A7F50BB'
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
