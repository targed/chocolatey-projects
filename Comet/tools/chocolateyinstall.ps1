$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://www.perplexity.ai/rest/browser/download?channel=stable&platform=win_x64&mini=1'
  softwareName   = 'comet*'
  checksum       = '8664182A6E163883A30BD43682B5AF4FBF204203FA8672C903FDAAB8165D9BC7'
  checksumType   = 'sha256'
  
  silentArgs     = '/VERYSILENT'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs


# $timeout = 60
# $timer = [System.Diagnostics.Stopwatch]::StartNew()

# Write-Host "Waiting for Cursor process to start..."
# while ($timer.Elapsed.TotalSeconds -lt $timeout) {
#   $process = Get-Process -Name "cursor" -ErrorAction SilentlyContinue
#   if ($process) {
#     Start-Sleep -Seconds 10  # Give it a few seconds to fully initialize
#     Write-Host "Terminating Cursor process..."
#     taskkill /F /IM "cursor.exe" /T
#     break
#   }
#   Start-Sleep -Seconds 1
# }

# if ($timer.Elapsed.TotalSeconds -ge $timeout) {
#   Write-Warning "Timeout waiting for Cursor process"
# }