$ErrorActionPreference = 'Stop'
$VerbosePreference = 'SilentlyContinue'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$version = "2.15.1"
$url = "https://github.com/TumblThreeApp/TumblThree/releases/download/v${version}/TumblThree-v${version}-x64-Application.zip"
$checksum = "D9CB5692C9978E818238E63A6A3CA56029BE58E4641C4B7DA32B9EEE2117996D"

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
