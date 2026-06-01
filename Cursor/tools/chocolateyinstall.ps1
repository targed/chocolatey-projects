$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# Get package parameters
$pp = Get-PackageParameters

# We store both URLs and Checksums here so the Updater script can find and update them via regex.
# url/checksum are for the User installer.
# url64bit/checksum64 are for the System installer.
# We don't pass all four to Install-ChocolateyPackage directly because they are both x64, 
# and it would prioritize url64bit incorrectly if the user wants the User installer.
$updaterDummyVariables = @{
  url        = 'https://downloads.cursor.com/production/81fcf2931d7687b4ff3f3017858d0c6dee7e2a68/win32/x64/user-setup/CursorUserSetup-x64-3.6.31.exe'
  checksum   = 'C6C45ED271986DCC5CFFB64811156D395CCB9B60C3D9FF45A20C56781907AA6E'
  url64bit   = 'https://downloads.cursor.com/production/81fcf2931d7687b4ff3f3017858d0c6dee7e2a68/win32/x64/system-setup/CursorSetup-x64-3.6.31.exe'
  checksum64 = 'DAE6B985732BFA4C9865F03699067C3DC1458B3C07EBE10996204C59165F93A6'
}

if ($pp.System) {
  # System installer
  Write-Host "Installing System-wide version..."
  $packageArgs = @{
    packageName    = $env:ChocolateyPackageName
    unzipLocation  = $toolsDir
    fileType       = 'exe'
    url            = $updaterDummyVariables.url64bit
    softwareName   = 'Cursor*'
    checksum       = $updaterDummyVariables.checksum64
    checksumType   = 'sha256'
      
    silentArgs     = '/VERYSILENT'
    validExitCodes = @(0, 3010, 1641)
  }
}
else {
  # User installer (default)
  Write-Host "Installing User-level version..."
  $packageArgs = @{
    packageName    = $env:ChocolateyPackageName
    unzipLocation  = $toolsDir
    fileType       = 'exe'
    url            = $updaterDummyVariables.url
    softwareName   = 'Cursor*'
    checksum       = $updaterDummyVariables.checksum
    checksumType   = 'sha256'
      
    silentArgs     = '/VERYSILENT'
    validExitCodes = @(0, 3010, 1641)
  }
}

Install-ChocolateyPackage @packageArgs


$timeout = 60
$timer = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host "Waiting for Cursor process to start..."
while ($timer.Elapsed.TotalSeconds -lt $timeout) {
  $process = Get-Process -Name "cursor" -ErrorAction SilentlyContinue
  if ($process) {
    Start-Sleep -Seconds 10  # Give it a few seconds to fully initialize
    Write-Host "Terminating Cursor process..."
    taskkill /F /IM "cursor.exe" /T
    break
  }
  Start-Sleep -Seconds 1
}

if ($timer.Elapsed.TotalSeconds -ge $timeout) {
  Write-Warning "Timeout waiting for Cursor process"
}