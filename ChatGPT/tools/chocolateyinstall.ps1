
$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url = 'https://github.com/lencx/ChatGPT/releases/download/v0.10.3/ChatGPT_0.10.3_x64_en-US.msi'

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'msi'
  url            = $url

  softwareName   = 'ChatGPT*'

  checksum       = '545E342C5E3F8133E63DF8C10E70AA2E4B08A01818F86678B189F49EDFB70428'
  checksumType   = 'sha256'
  
  silentArgs     = '/quiet'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs

















