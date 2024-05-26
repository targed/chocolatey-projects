$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://downloader.cursor.sh/windows/nsis/x64'
  softwareName   = 'Cursor*'
  checksum       = '762C285F456FA8575D39BBBB3DE2B2C5999D883DC7D47D668EF903EAE5E4B84D'
  checksumType   = 'sha256'
  
  silentArgs     = '/S'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
