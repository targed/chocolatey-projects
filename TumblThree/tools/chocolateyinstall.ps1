$ErrorActionPreference = 'Stop'
$VerbosePreference = 'SilentlyContinue'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url = 'https://github.com/TumblThreeApp/TumblThree/releases/download/v2.12.0/TumblThree-v2.12.0-x64-Application.zip'

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'EXE'
  url            = $url
  softwareName   = 'TumblThree*'
  checksum       = 'C92A763518127EDCEBA8C0EE2EFA75A00AE427BC12AD3F02C715BCD9A07865D7'
  checksumType   = 'sha256'
  silentArgs     = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /NOICONS /NOCANCEL /NOLOG'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyZipPackage @packageArgs

# Install a shortcut on the desktop
Install-ChocolateyShortcut -shortcutFilePath "$env:USERPROFILE\Desktop\TumblThree.lnk" -targetPath "$($packageArgs.unzipLocation)\TumblThree.exe"
