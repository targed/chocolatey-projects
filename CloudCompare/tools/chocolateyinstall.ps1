$ErrorActionPreference = 'Continue'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'EXE' 
  url            = 'https://www.cloudcompare.org/release/CloudCompare_v2.13.2_setup_x64.exe'
  softwareName   = 'CloudCompare*' 
  checksum       = '2384FAAABDC10BA11D64652B324724481CBA6E2634CE5D1D95B2F9AC457DC163'
  checksumType   = 'sha256'

  # Need to create silentArgs that prevent the installer from popping up a window (Have not figgured that out yet)
  silentArgs     = '/S /VERYSILENT /SUPPRESSMSGBOXES /norestart /quiet /qn /norestart /l*v /SP- $locale'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs