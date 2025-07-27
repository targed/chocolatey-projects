$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://download.whispertyping.com/whispertypinginstaller.exe'
  softwareName   = 'WhisperTyping*'
  checksum       = 'B2706E3960311287ABCDB54868612ACA4D7C619ACFD0BD2BAAB018423A72AF5C'
  checksumType   = 'sha256'
  
  silentArgs     = '/VERYSILENT'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs