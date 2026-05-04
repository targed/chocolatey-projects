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
  url        = 'https://downloads.cursor.com/production/806df57ed3b6f1ee0175140d38039a38574ec722/win32/x64/user-setup/CursorUserSetup-x64-3.2.21.exe'
  checksum   = '3CAE8C8D32526108A24E03E3E3B7668DBF1C25DCEBA8CF9DCD2C37DA2DC1B8F9'
  url64bit   = 'https://downloads.cursor.com/production/806df57ed3b6f1ee0175140d38039a38574ec722/win32/x64/system-setup/CursorSetup-x64-3.2.21.exe'
  checksum64 = '67070634685B6C1840C85582A436FF4D9B27F66FFB544E979AD26B615BD9C353'
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