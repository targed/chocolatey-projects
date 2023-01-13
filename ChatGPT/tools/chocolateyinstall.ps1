
$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url = 'https://github.com/lencx/ChatGPT/releases/download/v0.8.1/ChatGPT_0.8.1_x64_en-US.msi'

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'msi'
  url            = $url

  softwareName   = 'ChatGPT*'

  checksum       = '013BA5ECB4258BA181FC61E54C644A6CA719A9BE02D174BA7EBCC237959AEE78'
  checksumType   = 'sha256'
  
  silentArgs     = '/s /v"/qn"'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs

















