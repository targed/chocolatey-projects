$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$version = "0.3.20"
$url = 'https://installers.lmstudio.ai/win32/x64/0.3.20-4/LM-Studio-0.3.20-4-x64.exe'
$checksum = '7A79885B985DBAF236841E9E70157DFA09B4BC92469AD89589A459116B6A5033'

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