$ErrorActionPreference = 'Continue'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'EXE'
  url            = 'https://dl.reasonix.io/desktop-v1.21.5/Reasonix-windows-amd64-installer.exe'
  softwareName   = 'reasonix-desktop*'
  checksum       = 'E69998A848C59C6835DAB75DEE039554C9B3FBD13F89E98F7D0833A47AF4158D'
  checksumType   = 'sha256'
  silentArgs     = '/S /VERYSILENT /SUPPRESSMSGBOXES /norestart /quiet /qn /norestart /l*v /SP- $locale'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
