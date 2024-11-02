$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'EXE' 
  url            = 'https://storage.googleapis.com/osprey-downloads-c02f6a0d-347c-492b-a752-3e0651722e97/nest-win-x64/Claude-Setup-x64.exe'
  softwareName   = 'Claude*' 
  checksum       = '07F100420CE6D0400A41AD4DA9683BF007DD82B29A6827A09CD5B6067EDFD966'
  checksumType   = 'sha256'
  silentArgs     = '/quiet /SD /v/qn'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs

# Install a shortcut on the desktop
Install-ChocolateyShortcut -shortcutFilePath "$env:USERPROFILE\Desktop\Claude.lnk" -targetPath "$toolsDir\Claude.exe"