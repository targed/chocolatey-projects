$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url = 'https://content.vexrobotics.com/vexcode/v5code/VEXcodeProV5_2_0_6.exe'

$cert = Get-ChildItem Cert:\CurrentUser\TrustedPublisher -Recurse | Where-Object { $_.Thumbprint -eq '548132fd02be43149355d0596c256c0fd4c5c578' }
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
  url            = $url

  softwareName   = 'VEXcode Pro*'

  checksum       = '77EA7499DFFC4B0992F311B79A32E813066D24A87D8BC257632679FF7732AB63'
  checksumType   = 'sha256'

  silentArgs     = "/SD /v/qn"
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs