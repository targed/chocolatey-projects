$ErrorActionPreference = 'Continue'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'MSI'
  url            = 'https://github.com/NuvioMedia/NuvioDesktop/releases/download/0.1.39-alpha/Nuvio-Windows-x64-0.1.39-alpha.msi'
  softwareName   = 'nuviodesktop*'
  checksum       = 'CF14E43AC5D54EE725368782EBFA0D57E3C23F059A48572EA6499F598ADD0A81'
  checksumType   = 'sha256'
  silentArgs     = '/quiet /qn /norestart'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
