$ErrorActionPreference = 'Stop'
$VerbosePreference = 'SilentlyContinue'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$version = "2.19.4"
$url = "https://github.com/TumblThreeApp/TumblThree/releases/download/v${version}/TumblThree-v${version}-x64-Application.zip"
$checksum = "E38CB7FE5322CDB45F6C8514C03110C6A92E1D83019C225A06E082F3F05AB965"

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

Install-ChocolateyZipPackage @packageArgs

# Install a shortcut on the desktop
Install-ChocolateyShortcut -shortcutFilePath "$env:USERPROFILE\Desktop\TumblThree.lnk" -targetPath "$($packageArgs.unzipLocation)\TumblThree.exe"
