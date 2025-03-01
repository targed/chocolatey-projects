$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://jmars.asu.edu/downloads/jmars_5/jmars_public/jmars_5_public.exe'
  softwareName   = 'JMARS*'
  checksum       = 'E9E4A5D48C7803BA8422A098933DD5EDC04C599A4FD7E1A1CB883BA812EDCE41'
  checksumType   = 'sha256'
  
  silentArgs     = '/S'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
