$ErrorActionPreference = 'Continue'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'MSI'
  url            = 'https://github.com/NuvioMedia/NuvioDesktop/releases/download/0.1.34-alpha/Nuvio-Windows-x64-0.1.34-alpha.msi'
  softwareName   = 'nuviodesktop*'
  checksum       = 'FF6DC069203CA9F7FDE0AEF7C8FA08C8E0A4B2EFC5039E8264033182061CD2DB'
  checksumType   = 'sha256'
  silentArgs     = '/quiet /qn /norestart'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
