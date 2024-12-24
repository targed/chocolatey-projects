$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://updater.grayjay.app/Apps/Grayjay.Desktop/Grayjay.Desktop-win-x64.zip'
  softwareName   = 'Grayjay*'
  checksum       = ''
  checksumType   = 'sha256'
  
  silentArgs     = '/S'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
