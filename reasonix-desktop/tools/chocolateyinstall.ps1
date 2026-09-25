$ErrorActionPreference = 'Continue'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'EXE'
  url            = 'https://github.com/esengine/DeepSeek-Reasonix/releases/download/desktop-v1.39.0/Reasonix-windows-amd64-installer.exe'
  softwareName   = 'reasonix-desktop*'
  checksum       = '55F8D4C803AC13E15973CB87D57F0385D7F84FA16292C49B76D3E7E9B2CB010B'
  checksumType   = 'sha256'
  silentArgs     = '/S /VERYSILENT /SUPPRESSMSGBOXES /norestart /quiet /qn /norestart /l*v /SP- $locale'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
