$ErrorActionPreference = 'Continue'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'MSI'
  url            = 'https://github.com/NuvioMedia/NuvioDesktop/releases/download/0.1.33-alpha/Nuvio-Windows-x64-0.1.33-alpha.msi'
  softwareName   = 'nuviodesktop*'
  checksum       = 'A60574364E2B1A253B62A0A93A7E9C6BA38971C3F2E36C10CC913CB8987CEE75'
  checksumType   = 'sha256'
  silentArgs     = '/quiet /qn /norestart'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
