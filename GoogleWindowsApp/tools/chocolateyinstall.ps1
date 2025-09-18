$ErrorActionPreference = 'Continue'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'EXE' 
  url            = 'https://dl.google.com/tag/s/appguid%3D%7B06A8089E-0B65-445D-B5C4-10B0D1B540F2%7D%26iid%3D%7BC81BC991-C197-1AAD-6717-571B5A938DFA%7D%26lang%3Den%26browser%3D4%26usagestats%3D1%26appname%3DGoogle%2520App%26needsadmin%3DTrue/windows-google-app/GoogleInstaller.exe'
  softwareName   = 'GoogleWindowsApp*' 
  checksum       = '93E5F85EADA6E8E52950CAAF45BAB5BF5B6C5E529EE4D80DB0F2EB3AD60B0065'
  checksumType   = 'sha256'

  silentArgs     = '/SILENT /NORESTART'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs

# $timeout = 60
# $timer = [System.Diagnostics.Stopwatch]::StartNew()

# Write-Host "Waiting for Google Windows App process to start..."
# while ($timer.Elapsed.TotalSeconds -lt $timeout) {
#   $process = Get-Process -Name "Google" -ErrorAction SilentlyContinue
#   if ($process) {
#     Start-Sleep -Seconds 10  # Give it a few seconds to fully initialize
#     Write-Host "Terminating Google Windows App process..."
#     taskkill /F /IM "google.exe" /T
#     break
#   }
#   Start-Sleep -Seconds 1
# }

# if ($timer.Elapsed.TotalSeconds -ge $timeout) {
#   Write-Warning "Timeout waiting for Google Windows App process"
# }