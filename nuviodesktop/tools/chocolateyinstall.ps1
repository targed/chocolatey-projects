$ErrorActionPreference = 'Continue'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'MSI'
  url            = 'https://github.com/NuvioMedia/NuvioDesktop/releases/download/0.1.30-alpha/Nuvio-Windows-x64-0.1.30-alpha.msi'
  softwareName   = 'nuviodesktop*'
  checksum       = '9D3AA82557AE2F02D2E5FC97A91DFF42630B971536CB527A7618F503356BF0E3'
  checksumType   = 'sha256'
  silentArgs     = '/quiet /qn /norestart'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
