$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://dv-binaries.s3.us-east-2.amazonaws.com/windows_x86_64/diversion_windows_x86_64.exe'
  softwareName   = 'Diversion*'
  checksum       = '97DAA3046C2AF5BE2937B23BEAB94854FED5F510D6F3E07BBA812545E461A786'
  checksumType   = 'sha256'
  
  silentArgs     = '/VERYSILENT'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs