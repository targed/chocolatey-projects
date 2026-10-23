$ErrorActionPreference = 'Continue'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'MSI'
  url            = 'https://github.com/NuvioMedia/NuvioDesktop/releases/download/0.1.32-alpha/Nuvio-Windows-x64-0.1.32-alpha.msi'
  softwareName   = 'nuviodesktop*'
  checksum       = '968281124B3D03E6C7CA080772236E8479D0AAA59B0A302A80F9DA20B21DEBDA'
  checksumType   = 'sha256'
  silentArgs     = '/quiet /qn /norestart'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
