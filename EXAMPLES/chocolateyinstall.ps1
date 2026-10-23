$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'EXE' 
  url            = 'https://storage.googleapis.com/osprey-downloads-c02f6a0d-347c-492b-a752-3e0651722e97/nest-win-x64/Claude-Setup-x64.exe'
  softwareName   = 'Claude*' 
  checksum       = 'DCD26688FB333423B38B87314F454A753489DEABDB10A2AD02237C0256373B14'
  checksumType   = 'sha256'

  # Need to create silentArgs that prevent the installer from popping up a window (Have not figgured that out yet)
  silentArgs     = '/S /VERYSILENT /SUPPRESSMSGBOXES /norestart /quiet /qn /norestart /l*v /SP- $locale'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs

# Claude desktop is installed by an installer, so we need to wait for the process to appear. 
# This installer does not obey the silent arguments but is needed to install the desktop.

# Wait for Claude process to appear (timeout after 60 seconds)
$timeout = 60
$timer = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host "Waiting for Claude process to start..."
while ($timer.Elapsed.TotalSeconds -lt $timeout) {
  $process = Get-Process -Name "claude" -ErrorAction SilentlyContinue
  if ($process) {
    Start-Sleep -Seconds 5  # Give it a few seconds to fully initialize
    Write-Host "Terminating Claude process..."
    taskkill /F /IM "claude.exe" /T
    break
  }
  Start-Sleep -Seconds 1
}

if ($timer.Elapsed.TotalSeconds -ge $timeout) {
  Write-Warning "Timeout waiting for Claude process"
}