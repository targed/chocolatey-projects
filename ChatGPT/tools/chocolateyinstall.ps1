
$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url = 'https://github.com/lencx/ChatGPT/releases/download/v0.10.1/ChatGPT_0.10.1_x64_en-US.msi'

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'msi'
  url            = $url

  softwareName   = 'ChatGPT*'

  checksum       = 'F47A330A14633877EF5F7E369A0A03D39A07F8D0D3FA598BC0C3A14D531698B2'
  checksumType   = 'sha256'
  
  silentArgs     = '/quiet'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs

















