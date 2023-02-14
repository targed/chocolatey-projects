$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url = 'https://github.com/lencx/ChatGPT/releases/download/v0.8.1/ChatGPT_0.8.1_x64_en-US.msi'

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'msi'
  url            = $url

  softwareName   = 'ChatGPT*'

  checksum       = '01BAC6E0DEA113CFA6E3CC1CF6631B12B03CBBB30481695AAEC5E9E7291B4FF5'
  checksumType   = 'sha256'
  
  silentArgs     = '/quiet'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs