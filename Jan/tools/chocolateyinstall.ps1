$ErrorActionPreference = 'Stop'
$VerbosePreference = 'SilentlyContinue'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$version = "0.7.9"
$url = "https://github.com/menloresearch/jan/releases/download/v${version}/Jan_${version}_x64-setup.exe"
$checksum = "8CAEF1D3B5DE3E8CFC15B43BF8071BCA9E9D32DA054514387F9ABCE31DB075B0"

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
