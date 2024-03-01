$ErrorActionPreference = 'Stop'

$packageName= $env:ChocolateyPackageName
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://github.com/TumblThreeApp/TumblThree/releases/download/v2.12.0/TumblThree-v2.12.0-x64-Application.zip'
$setupName  = 'TumblThree.exe'

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'EXE'
  url            = $url
  softwareName   = 'TumblThree*'
  checksum       = 'F09F3872F10F8BDC8F84F93C2CEB369A587EB9824B9EC8A7D64B64B3B40B5A34'
  checksumType   = 'sha256'
  
  silentArgs     = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'
  validExitCodes = @(0, 3010, 1641)
}


Install-ChocolateyZipPackage @packageArgs

$packageArgs.file = Join-Path -Path $toolsDir -ChildPath $setupName
Install-ChocolateyInstallPackage @packageArgs
