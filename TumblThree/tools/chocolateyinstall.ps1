$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'zip'
  url            = 'https://github.com/TumblThreeApp/TumblThree/releases/download/v2.12.0/TumblThree-v2.12.0-x64-Application.zip'
  softwareName   = 'TumblThree*'
  checksum       = '4AACB2D592EB488CA8ABD4F67804F70DC57C404708480878026AAED4065D8C2E'
  checksumType   = 'sha256'
  
  silentArgs     = '/quiet'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
