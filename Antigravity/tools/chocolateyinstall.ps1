$ErrorActionPreference = 'Stop'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://storage.googleapis.com/antigravity-public/antigravity-hub/2.32.1-6001966350991360/windows-x64/Antigravity-x64.exe'
  softwareName   = 'Antigravity*'
  checksum       = 'F216EE69D6A6D0C69F7FCA01E3CCEF9F0F1D78F861FA24891A6DB185D6FA5EE1'
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
