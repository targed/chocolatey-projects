$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://anysphere-binaries.s3.us-east-1.amazonaws.com/production/ae378be9dc2f5f1a6a1a220c6e25f9f03c8d4e19/win32/x64/user-setup/CursorUserSetup-x64-0.46.11.exe'
  softwareName   = 'Cursor*'
  checksum       = '56BE08FF0CBFBA41CE86BD78B43420ABEC6232AA2ADCBD5ABF98210A9DF3E1C0'
  checksumType   = 'sha256'
  
  silentArgs     = '/SILENT'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
