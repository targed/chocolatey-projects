$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://downloader.cursor.sh/windows/nsis/x64'
  softwareName   = 'Cursor*'
  checksum       = '60FCBB89EAD6E52DBCA18B5A870C86BBEBD66BFF7D68401C4FBF215E26B8A652'
  checksumType   = 'sha256'
  
  silentArgs     = '/S'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
