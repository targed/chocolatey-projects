$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://storage.googleapis.com/antigravity-public/antigravity-hub/2.9.1-4871453687021568/windows-x64/Antigravity-x64.exe'
  softwareName   = 'Antigravity*'
  checksum       = '84A6CDCB0136F887B599A62B70B9B0A8D3A621224FC167A1F53033EE600409CD'
  checksumType   = 'sha256'
  
  silentArgs     = '/S /VERYSILENT /SUPPRESSMSGBOXES /norestart /quiet /qn /norestart /l*v /SP- $locale'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs

$timeout = 60
$timer = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host "Waiting for Antigravity process to start..."
while ($timer.Elapsed.TotalSeconds -lt $timeout) {
  $process = Get-Process -Name "antigravity" -ErrorAction SilentlyContinue
  if ($process) {
    Start-Sleep -Seconds 10  # Give it a few seconds to fully initialize
    Write-Host "Terminating Antigravity process..."
    taskkill /F /IM "antigravity.exe" /T
    break
  }
  Start-Sleep -Seconds 1
}

if ($timer.Elapsed.TotalSeconds -ge $timeout) {
  Write-Warning "Timeout waiting for Antigravity process"
}