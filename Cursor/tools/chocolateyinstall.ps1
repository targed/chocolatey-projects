$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://anysphere-binaries.s3.us-east-1.amazonaws.com/production/be4f0962469499f009005e66867c8402202ff0b7/win32/x64/user-setup/CursorUserSetup-x64-0.46.8.exe'
  softwareName   = 'Cursor*'
  checksum       = 'D89F7AE12592ABC3600221FCAF4B6AB127EF4DB9AB721875F3DE07EB35A52527'
  checksumType   = 'sha256'
  
  silentArgs     = '/SILENT'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
