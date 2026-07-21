$ErrorActionPreference = 'Continue'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'MSI'
  url            = 'https://github.com/NuvioMedia/NuvioDesktop/releases/download/0.1.13-alpha/Nuvio-Windows-x64-0.1.13-alpha.msi'
  softwareName   = 'nuviodesktop*'
  checksum       = '820BF39613B67632796A15436A03412E1B2CA607D8C113BA0ECCDCDA8DF23ABF'
  checksumType   = 'sha256'
  silentArgs     = '/quiet /qn /norestart'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
