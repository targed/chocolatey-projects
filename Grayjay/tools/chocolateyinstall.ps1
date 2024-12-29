$ErrorActionPreference = 'Stop'
$VerbosePreference = 'SilentlyContinue'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://updater.grayjay.app/Apps/Grayjay.Desktop/Grayjay.Desktop-win-x64.zip'
  softwareName   = 'Grayjay*'
  checksum       = 'F9A18730F17917CB8B55613EAC5EAAC895CBE778FAF39B63BE142E700C492E80'
  checksumType   = 'sha256'
  
  silentArgs     = '/S'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyZipPackage @packageArgs

Install-ChocolateyShortcut -shortcutFilePath "$env:USERPROFILE\Desktop\Grayjay.lnk" -targetPath "$($packageArgs.unzipLocation)\Grayjay.Desktop-win-x64-v2\Grayjay.exe" -workingDirectory "$($packageArgs.unzipLocation)\Grayjay.Desktop-win-x64-v2"

# Set "Run as Administrator" flag on the shortcut
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut("$env:USERPROFILE\Desktop\Grayjay.lnk")
$bytes = [System.IO.File]::ReadAllBytes("$env:USERPROFILE\Desktop\Grayjay.lnk")
$bytes[0x15] = $bytes[0x15] -bor 0x20
[System.IO.File]::WriteAllBytes("$env:USERPROFILE\Desktop\Grayjay.lnk", $bytes)