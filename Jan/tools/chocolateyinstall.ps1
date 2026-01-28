$ErrorActionPreference = 'Stop'
$VerbosePreference = 'SilentlyContinue'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$version = "0.7.6"
$url = "https://github.com/menloresearch/jan/releases/download/v${version}/Jan_${version}_x64-setup.exe"
$checksum = "7D4191FE747E5756451BC0A19708F708CE2F2711B807BB4B292CFEECCF377F08"

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
