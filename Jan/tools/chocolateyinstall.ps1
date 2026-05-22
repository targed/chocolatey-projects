$ErrorActionPreference = 'Stop'
$VerbosePreference = 'SilentlyContinue'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$version = "0.8.0"
$url = "https://github.com/menloresearch/jan/releases/download/v${version}/Jan_${version}_x64-setup.exe"
$checksum = "35858BA6DA4AE9A24FD055A1FD34FF6EA7C02C9FB74201867EF50172C920B757"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = "EXE"
  version        = $version
  url            = $url
  checksum       = $checksum
  checksumType   = "sha256"
  silentArgs     = "/S /VERYSILENT /SUPPRESSMSGBOXES /norestart /quiet /qn /norestart /l*v /SP- $locale"
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
