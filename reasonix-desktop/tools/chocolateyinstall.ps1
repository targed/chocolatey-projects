$ErrorActionPreference = 'Continue'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'EXE'
  url            = 'https://github.com/esengine/DeepSeek-Reasonix/releases/download/desktop-v1.39.5/Reasonix-windows-amd64-installer.exe'
  softwareName   = 'reasonix-desktop*'
  checksum       = 'C39FF76F6B3A81507A9B16756A6C6F60762D959EBB35E79473E704FE32BF8F09'
  checksumType   = 'sha256'
  silentArgs     = '/S /VERYSILENT /SUPPRESSMSGBOXES /norestart /quiet /qn /norestart /l*v /SP- $locale'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
