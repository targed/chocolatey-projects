$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$version = "0.3.27"
$url = 'https://installers.lmstudio.ai/win32/x64/0.3.27-4/LM-Studio-0.3.27-4-x64.exe'
$checksum = '626F9B8AA269FD7D35BBC65D5624A117A01BEFA93AB815D6F9D08AB0F837CF67'

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'EXE' 
  version        = $version
  url            = $url
  softwareName   = 'LM-Studio*' 
  checksum       = $checksum
  checksumType   = 'sha256'

  # Need to create silentArgs that prevent the installer from popping up a window (Have not figgured that out yet)
  silentArgs     = '/S /VERYSILENT /SUPPRESSMSGBOXES /norestart /quiet /qn /norestart /l*v /SP- $locale'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs