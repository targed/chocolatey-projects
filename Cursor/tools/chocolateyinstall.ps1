$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://download.cursor.sh/windows/nsis/x64'
  softwareName   = 'Cursor*'
  checksum       = '8006853A651B907D6FF8BA396D2119C9F85403D82DAC872B48294BCC44D64DDD'
  checksumType   = 'sha256'
  
  silentArgs     = '/S'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
