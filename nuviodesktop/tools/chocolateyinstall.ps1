$ErrorActionPreference = 'Continue'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'MSI'
  url            = 'https://github.com/NuvioMedia/NuvioDesktop/releases/download/0.1.31-alpha/Nuvio-Windows-x64-0.1.31-alpha.msi'
  softwareName   = 'nuviodesktop*'
  checksum       = 'B0471E1CEB7D164B5280E2F2E861A4E99C6A881EDE82F9E0633E290B28EBC7C9'
  checksumType   = 'sha256'
  silentArgs     = '/quiet /qn /norestart'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
