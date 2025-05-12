$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url = 'https://content.vexrobotics.com/vexcode/4/v5/VEXcode%20V5-4.0.7-latest-win-x64.exe'

$cert = Get-ChildItem Cert:\CurrentUser\TrustedPublisher -Recurse | Where-Object { $_.Thumbprint -eq 'f69c63f8bbfd55e3f7b326320f990c85ea937a89' }
if (!$cert) {
  $toolsPath = Split-Path $MyInvocation.MyCommand.Definition
  Start-ChocolateyProcessAsAdmin "certutil -addstore 'TrustedPublisher' '$toolsPath\VEXrobotics.cer'"
}
$cert1 = Get-ChildItem Cert:\CurrentUser\TrustedPublisher -Recurse | Where-Object { $_.Thumbprint -eq '24369f7f00a9d19d11bbf460215027cda25d99a8' }
if (!$cert1) {
  $toolsPath = Split-Path $MyInvocation.MyCommand.Definition
  Start-ChocolateyProcessAsAdmin "certutil -addstore 'TrustedPublisher' '$toolsPath\Robomatter.cer'"
}

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'exe'
  url            = 'https://content.vexrobotics.com/vexcode/4/v5/VEXcode%20V5-4.0.7-latest-win-x64.exe'

  softwareName   = 'VEXcode*'

  checksum       = '8D82E09119A8BC39599C0A5092666B3E2E6DB427E15CA3304566DDD5FC7C529E'
  checksumType   = 'sha256'

  silentArgs     = '/S /VERYSILENT /SUPPRESSMSGBOXES /norestart /quiet /qn /norestart /l*v /SP- $locale'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs