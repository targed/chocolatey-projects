$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://downloader.cursor.sh/windows/nsis/x64'
  softwareName   = 'Cursor*'
  checksum       = '2786F80344085CA6657C9F283F97B98C61A933E27CCB7D34B682CC3EA5F9A9FE'
  checksumType   = 'sha256'
  
  silentArgs     = '/S'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
