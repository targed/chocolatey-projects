$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://downloader.cursor.sh/windows/nsis/x64'
  softwareName   = 'Cursor*'
  checksum       = '71C746465D4CAAE39B7A878EED3C80AAB2271DC3569B140EEE6DC2679E16BBCE'
  checksumType   = 'sha256'
  
  silentArgs     = '/S'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
