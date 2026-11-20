$ErrorActionPreference = 'Continue'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'MSI'
  url            = 'https://github.com/NuvioMedia/NuvioDesktop/releases/download/0.1.38-alpha/Nuvio-Windows-x64-0.1.38-alpha.msi'
  softwareName   = 'nuviodesktop*'
  checksum       = '6B9E27A268DCA638A648968E43C3D90E30EC5407C5C99C4B630E957F0BF90DF3'
  checksumType   = 'sha256'
  silentArgs     = '/quiet /qn /norestart'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
