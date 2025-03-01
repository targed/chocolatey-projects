$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://anysphere-binaries.s3.us-east-1.amazonaws.com/production/3611c5390c448b242ab97e328493bb8ef7241e61/win32/x64/user-setup/CursorUserSetup-x64-0.46.7.exe'
  softwareName   = 'Cursor*'
  checksum       = '81DAB6FE2C887A5BB8C0245F8AB2C26D898711397FC30442B656CC9971E20334'
  checksumType   = 'sha256'
  
  silentArgs     = '/SILENT'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
