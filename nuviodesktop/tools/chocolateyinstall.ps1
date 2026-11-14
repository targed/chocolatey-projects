$ErrorActionPreference = 'Continue'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'MSI'
  url            = 'https://github.com/NuvioMedia/NuvioDesktop/releases/download/0.1.36-alpha/Nuvio-Windows-x64-0.1.36-alpha.msi'
  softwareName   = 'nuviodesktop*'
  checksum       = '0CEADB883ADF25F70F1C3E8B1986C2516E63753FEB4BD88D6A4B95500135BE12'
  checksumType   = 'sha256'
  silentArgs     = '/quiet /qn /norestart'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
