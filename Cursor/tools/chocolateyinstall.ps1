$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://downloads.cursor.com/production/e9ee1339915a927dfb2df4a836dd9c8337e17cc2/win32/x64/user-setup/CursorUserSetup-x64-3.2.11.exe'
  softwareName   = 'Cursor*'
  checksum       = '521F6788D9D3026946C9BC23716FAF3A5E592C318B817E14E0B9A4BD2620B8CC'
  checksumType   = 'sha256'
  
  silentArgs     = '/VERYSILENT'
  validExitCodes = @(0, 3010, 1641)
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