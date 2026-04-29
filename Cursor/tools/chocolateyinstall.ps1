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
  url        = 'https://downloads.cursor.com/production/3e548838cf824b70851dd3ef27d0c6aae371b3f6/win32/x64/user-setup/CursorUserSetup-x64-3.2.16.exe'
  checksum   = '46C29C5E3F5E18AD0A4A6F33F9BFAFE17427BF641CAFC4357F98DC6303624249'
  url64bit   = 'https://downloads.cursor.com/production/3e548838cf824b70851dd3ef27d0c6aae371b3f6/win32/x64/system-setup/CursorSetup-x64-3.2.16.exe'
  checksum64 = 'E26FFE026115D3C397C6FEBD0BF3F9A9B526D5E70E85A1D7DE116167DFA814D2'
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