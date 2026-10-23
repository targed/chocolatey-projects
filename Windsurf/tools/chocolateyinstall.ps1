$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$version = "1.7.1"
$url = 'https://windsurf-stable.codeiumdata.com/win32-x64-user/stable/b21eedafd0e27ae3d0a6e454346f7b02178f0949/WindsurfUserSetup-x64-1.7.1.exe'
$checksum = 'FFB462C95818CC34503EB42AB094479501008AD6474CB2D5C6D2D757CB7CA661'

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'EXE' 
  version        = $version
  url            = $url
  softwareName   = 'Windsurf*' 
  checksum       = $checksum
  checksumType   = 'sha256'

  # Need to create silentArgs that prevent the installer from popping up a window (Have not figgured that out yet)
  silentArgs     = '/S /VERYSILENT /SUPPRESSMSGBOXES /norestart /quiet /qn /norestart /l*v /SP- $locale'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs