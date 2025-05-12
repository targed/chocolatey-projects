$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://downloads.cursor.com/production/0781e811de386a0c5bcb07ceb259df8ff8246a52/win32/x64/user-setup/CursorUserSetup-x64-0.49.6.exe'
  softwareName   = 'Cursor*'
  checksum       = '78A5BC17FFAF9C8B382AD07D0D97237D1F32A0350061A5DF8D8EE903BBD7D674'
  checksumType   = 'sha256'
  
  silentArgs     = '/VERYSILENT'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
