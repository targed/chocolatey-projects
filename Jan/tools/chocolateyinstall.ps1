$ErrorActionPreference = 'Stop'
$VerbosePreference = 'SilentlyContinue'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$version = "0.8.3"
$url = "https://github.com/menloresearch/jan/releases/download/v${version}/Jan_${version}_x64-setup.exe"
$checksum = "411DC07174F2DBDA01FFC807CEDB9ECF75CC6730057ED59432C7CA2D466FB939"

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
