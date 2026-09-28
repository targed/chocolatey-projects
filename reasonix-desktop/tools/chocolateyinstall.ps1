$ErrorActionPreference = 'Continue'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'EXE'
  url            = 'https://github.com/esengine/DeepSeek-Reasonix/releases/download/desktop-v1.39.3/Reasonix-windows-amd64-installer.exe'
  softwareName   = 'reasonix-desktop*'
  checksum       = 'EAE0009D3D56AC5D21EE0F558B7FD22620925C0C90FA1A98B016E333C0ED4C63'
  checksumType   = 'sha256'
  silentArgs     = '/S /VERYSILENT /SUPPRESSMSGBOXES /norestart /quiet /qn /norestart /l*v /SP- $locale'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
