$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://jmars.asu.edu/downloads/jmars_5/jmars_public/jmars_5_public.exe'
  softwareName   = 'JMARS*'
  checksum       = '31DAD8AAD37C27A423765F53C473DAB1A4AE8A4F3629584A58385A3A68C352BC'
  checksumType   = 'sha256'
  
  silentArgs     = '/S /VERYSILENT /SUPPRESSMSGBOXES /norestart /quiet /qn /norestart /l*v /SP- $locale'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
