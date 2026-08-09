$ErrorActionPreference = 'Continue'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'ZIP'
  url            = 'https://github.com/esengine/DeepSeek-Reasonix/releases/download/v1.21.5/reasonix-windows-amd64.zip'
  softwareName   = 'reasonix-cli*'
  checksum       = '20B2D9B03A25C6DB5788F24815428BC6C48C458CD4509D6D3D05FB481FB66DA9'
  checksumType   = 'sha256'
  silentArgs     = '/S /VERYSILENT /SUPPRESSMSGBOXES /norestart /quiet /qn /norestart /l*v /SP- $locale'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
