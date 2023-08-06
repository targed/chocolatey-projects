$ErrorActionPreference = 'Stop'

$url = 'https://github.com/lencx/nofwl/releases/download/v0.1.0/NoFWL_0.1.0_windows_x86_64.msi'

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'msi'
  url            = $url

  softwareName   = 'NoFWL*'

  checksum       = 'EA24E9E631A1D6DF0A7741CCCA312A5C7C2B241C9CF4E408CAD0A6B670EB0DAC'
  checksumType   = 'sha256'
  
  silentArgs     = '/quiet'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs