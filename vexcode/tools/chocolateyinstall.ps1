$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url = 'https://link.vex.com/vexcode-v5blocks-windows'

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
  url            = 'https://link.vex.com/vexcode-v5blocks-windows'

  softwareName   = 'VEXcode*'

  checksum       = '22B2074049F2D5821C5F930BA0FCE5ADF4914A23037AED66E425C0AB414246B5'
  checksumType   = 'sha256'

  silentArgs     = '/SD /v"/qn"'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs