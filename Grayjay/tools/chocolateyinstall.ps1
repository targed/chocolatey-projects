$ErrorActionPreference = 'Stop'
$VerbosePreference = 'SilentlyContinue'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$checksum = 'D98B164AAD09E0F3FF4031A6E519E3D783594A0DE058CD1E63079577E11705B7'

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'EXE'
  url            = 'https://updater.grayjay.app/Apps/Grayjay.Desktop/Grayjay.Desktop-win-x64.zip'
  softwareName   = 'Grayjay*'
  checksum       = $checksum
  checksumType   = 'sha256'
  
  silentArgs     = '/S'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyZipPackage @packageArgs

Install-ChocolateyShortcut -shortcutFilePath "$env:USERPROFILE\Desktop\Grayjay.lnk" -targetPath "$($packageArgs.unzipLocation)\Grayjay.Desktop-win-x64-v5\Grayjay.exe" -workingDirectory "$($packageArgs.unzipLocation)\Grayjay.Desktop-win-x64-v5"

# Set "Run as Administrator" flag on the shortcut
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut("$env:USERPROFILE\Desktop\Grayjay.lnk")
$bytes = [System.IO.File]::ReadAllBytes("$env:USERPROFILE\Desktop\Grayjay.lnk")
$bytes[0x15] = $bytes[0x15] -bor 0x20
[System.IO.File]::WriteAllBytes("$env:USERPROFILE\Desktop\Grayjay.lnk", $bytes)