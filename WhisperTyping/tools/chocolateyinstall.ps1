$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://download.whispertyping.com/wt/WhisperTypingInstaller-4.4.1.exe'
  softwareName   = 'WhisperTyping*'
  checksum       = 'D4AA765DAF26095DA3A5EA87778CAD81526EEDA9AF8F089F1BA6D4C09A22641F'
  checksumType   = 'sha256'
  
  silentArgs     = '/qn'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs

$timeout = 10
$timer = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host "Waiting for WhisperTyping process to start..."
while ($timer.Elapsed.TotalSeconds -lt $timeout) {
  $process = Get-Process -Name "WhisperTyping" -ErrorAction SilentlyContinue
  if ($process) {
    Start-Sleep -Seconds 10  # Give it a few seconds to fully initialize
    Write-Host "Terminating WhisperTyping process..."
    taskkill /F /IM "WhisperTyping.exe" /T
    break
  }
  Start-Sleep -Seconds 1
}

if ($timer.Elapsed.TotalSeconds -ge $timeout) {
  Write-Warning "Timeout waiting for WhisperTyping process"
}