$ErrorActionPreference = 'Stop'
$VerbosePreference = 'SilentlyContinue'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$version = "0.7.2"
$url = "https://github.com/menloresearch/jan/releases/download/v${version}/Jan_${version}_x64-setup.exe"
$checksum = "C80FF1C65A7D53CF8D54BD173EF94B7B87CC3BB28050731DA3B9AEC44F591F42"

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
