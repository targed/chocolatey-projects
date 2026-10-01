$ErrorActionPreference = 'Continue'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'EXE'
  url            = 'https://github.com/esengine/DeepSeek-Reasonix/releases/download/desktop-v1.39.6/Reasonix-windows-amd64-installer.exe'
  softwareName   = 'reasonix-desktop*'
  checksum       = '4A9606D1AADAF24C5CD97EBED6320B1720A755B22A706269D81F58D8F2120451'
  checksumType   = 'sha256'
  silentArgs     = '/S /VERYSILENT /SUPPRESSMSGBOXES /norestart /quiet /qn /norestart /l*v /SP- $locale'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
