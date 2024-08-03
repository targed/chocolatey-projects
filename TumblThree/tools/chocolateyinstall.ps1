$ErrorActionPreference = 'Stop'
$VerbosePreference = 'SilentlyContinue'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'EXE'
  url            = 'https://github.com/TumblThreeApp/TumblThree/releases/download/v2.14.2/TumblThree-v2.14.2-x64-Application.zip'
  softwareName   = 'TumblThree*'
  checksum       = '0A5605EB49547F84D3A1E6A6E0551018CC890F03CAB1B37AD88926687B63E89A'
  checksumType   = 'sha256'
  silentArgs     = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /NOICONS /NOCANCEL /NOLOG'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyZipPackage @packageArgs

# Install a shortcut on the desktop
Install-ChocolateyShortcut -shortcutFilePath "$env:USERPROFILE\Desktop\TumblThree.lnk" -targetPath "$($packageArgs.unzipLocation)\TumblThree.exe"
