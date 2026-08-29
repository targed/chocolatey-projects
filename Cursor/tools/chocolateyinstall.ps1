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
  url        = 'https://downloads.cursor.com/production/2ba48ff3f7514cc4643c52ca9f7b3173d9b66137/win32/x64/user-setup/CursorUserSetup-x64-3.18.9.exe'
  checksum   = '22E905DBAFA2CF47B61D68404AB058A4B989BBB200F1B8CECB1E0DC5908BABE8'
  url64bit   = 'https://downloads.cursor.com/production/2ba48ff3f7514cc4643c52ca9f7b3173d9b66137/win32/x64/system-setup/CursorSetup-x64-3.18.9.exe'
  checksum64 = 'CB652163A19BEF5CA186392DAF3353056FAFB440D696BA2754ECE1AC047D59AC'
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