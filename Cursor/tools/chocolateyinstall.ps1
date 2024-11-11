$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://downloader.cursor.sh/windows/nsis/x64'
  softwareName   = 'Cursor*'
  checksum       = '081D0D28FB3904E85A2C324940C2F4110B60A32CC9DC4F0B03AECC089A169A26'
  checksumType   = 'sha256'
  
  silentArgs     = '/S'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
