$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://get.microsoft.com/installer/download/9NT1R1C2HH7J?hl=en-us'
  softwareName   = 'ChatGPT-Desktop*'
  checksum       = '829B69A35A8AE782F4D3F0288B077A8F8DEC804C6B97EE48AE2F44E90F5883F9'
  checksumType   = 'sha256'
  
  silentArgs     = '/quiet'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
