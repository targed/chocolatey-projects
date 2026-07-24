$ErrorActionPreference = 'Continue'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'MSI'
  url            = 'https://github.com/wavetermdev/waveterm/releases/download/v0.14.5/Wave-win32-x64-0.14.5.msi'
  softwareName   = 'waveterm*'
  checksum       = 'A370081703226EF51F113AF68716373A3E732A006D82C5A769ABFBFB0AC7EA4B'
  checksumType   = 'sha256'
  silentArgs     = '/quiet /qn /norestart'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
