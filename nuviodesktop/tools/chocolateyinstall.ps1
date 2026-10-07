$ErrorActionPreference = 'Continue'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'MSI'
  url            = 'https://github.com/NuvioMedia/NuvioDesktop/releases/download/0.1.27-alpha/Nuvio-Windows-x64-0.1.27-alpha.msi'
  softwareName   = 'nuviodesktop*'
  checksum       = '75A58EF18FCFA6FCF75D752D8B4971AAAE601E55373A9B9A7567B08E4097FD4E'
  checksumType   = 'sha256'
  silentArgs     = '/quiet /qn /norestart'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
