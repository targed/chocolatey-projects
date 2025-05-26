$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$version = "0.3.16"
$url = 'https://installers.lmstudio.ai/win32/x64/0.3.16-7/LM-Studio-0.3.16-7-x64.exe'
$checksum = '1A9569DB0ECB9F2CA0A47CEC294218BF87B0B140120843B7CE66B15E71E17C5B'

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