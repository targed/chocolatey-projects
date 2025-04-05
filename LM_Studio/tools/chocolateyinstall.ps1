$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$version = "0.3.8"
$url = 'https://installers.lmstudio.ai/win32/x64/0.3.14-5/LM-Studio-0.3.14-5-x64.exe'
$checksum = 'B9DE1A02697822A3C5455A91163E8AE7B425DCE4059AA8B1B7BB359CFFEB2D8A'

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'EXE' 
  version        = $version
  url            = $url
  softwareName   = 'LM-Studio*' 
  checksum       = $checksum
  checksumType   = 'sha256'

  # Need to create silentArgs that prevent the installer from popping up a window (Have not figgured that out yet)
  silentArgs     = '/S /VERYSILENT /SUPPRESSMSGBOXES /norestart /quiet /qn /norestart /l*v /SP- $locale'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs