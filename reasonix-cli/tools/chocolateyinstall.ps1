$ErrorActionPreference = 'Continue'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'ZIP'
  url            = 'https://github.com/esengine/DeepSeek-Reasonix/releases/download/v1.21.5/reasonix-windows-amd64.zip'
  softwareName   = 'reasonix-cli*'
  checksum       = '3C34350798772F408C0D8ADEE15800E4EB6B9A6D8A5324D75D04B72B47BCCF81'
  checksumType   = 'sha256'
  silentArgs     = '/S /VERYSILENT /SUPPRESSMSGBOXES /norestart /quiet /qn /norestart /l*v /SP- $locale'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyZipPackage @packageArgs
