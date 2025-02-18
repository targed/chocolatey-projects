$ErrorActionPreference = 'Stop'
$VerbosePreference = 'SilentlyContinue'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$version = "0.5.14"
$url = "https://github.com/janhq/jan/releases/download/jan-win-x64-${version}.exe"
$checksum = "65A90BBA5BDDA7B5EAEE212C50873CBA82168833B2C185BE4832C94FA45C3BE0"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = "EXE"
  version        = $version
  url            = $url
  checksum       = $checksum
  checksumType   = "sha256"
  silentArgs     = "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /NOICONS /NOCANCEL /NOLOG"
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs

# Install a shortcut on the desktop
# Install-ChocolateyShortcut -shortcutFilePath "$env:USERPROFILE\Desktop\TumblThree.lnk" -targetPath "$($packageArgs.unzipLocation)\TumblThree.exe"
