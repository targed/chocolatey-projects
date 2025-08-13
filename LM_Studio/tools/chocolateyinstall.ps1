$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$version = "0.3.23"
$url = 'https://installers.lmstudio.ai/win32/x64/0.3.23-3/LM-Studio-0.3.23-3-x64.exe'
$checksum = '492F86B7EEF5FDA257FEA2F64CEFFE47DE68DE9D9C25EEAD85F2FCD77B7CA96C'

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