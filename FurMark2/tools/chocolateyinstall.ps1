$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://www.geeks3d.com/dl/get/831'
  softwareName   = 'FurMark*'
  checksum       = '88C07E0C674676BB486D3D46D73605925983B3AFA8F292A2D9707AD919A3EA9B'
  checksumType   = 'sha256'

  silentArgs     = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs