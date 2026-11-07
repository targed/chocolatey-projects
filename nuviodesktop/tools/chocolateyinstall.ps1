$ErrorActionPreference = 'Continue'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'MSI'
  url            = 'https://github.com/NuvioMedia/NuvioDesktop/releases/download/0.1.35-alpha/Nuvio-Windows-x64-0.1.35-alpha.msi'
  softwareName   = 'nuviodesktop*'
  checksum       = '5D9094EDD1870F1592B2D4B35569BD602AE2BE6F6F0C4C7E2F787D7D18B13298'
  checksumType   = 'sha256'
  silentArgs     = '/quiet /qn /norestart'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
