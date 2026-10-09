$ErrorActionPreference = 'Continue'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'MSI'
  url            = 'https://github.com/NuvioMedia/NuvioDesktop/releases/download/0.1.29-alpha/Nuvio-Windows-x64-0.1.29-alpha.msi'
  softwareName   = 'nuviodesktop*'
  checksum       = 'BD3144162E403E5041A7356F839EEE1EC00B954B001524F818252AA8A0E31DDC'
  checksumType   = 'sha256'
  silentArgs     = '/quiet /qn /norestart'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
