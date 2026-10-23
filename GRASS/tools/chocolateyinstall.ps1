$ErrorActionPreference = 'Continue'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'EXE' 
  url            = 'https://grass.osgeo.org/grass84/binary/mswindows/native/WinGRASS-8.4.1-1-Setup.exe'
  softwareName   = 'GRASS*'
  checksum       = '36F457524AFC539E0E66A035DE7F7AF9103160DBAE0AD6D5AD24775CB0FE656D'
  checksumType   = 'sha256'

  # Need to create silentArgs that prevent the installer from popping up a window (Have not figgured that out yet)
  silentArgs     = '/S /VERYSILENT /SUPPRESSMSGBOXES /norestart /quiet /qn /norestart /l*v /SP- $locale'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs