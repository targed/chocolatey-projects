$ErrorActionPreference = 'Stop'

$folderName = "AnthropicClaude"

# Remove Claude directory in old location if it exists (ProgramData/$USER$)
$oldUnzipLocation = Join-Path ([Environment]::GetFolderPath("CommonApplicationData")) $folderName
if (Test-Path $oldUnzipLocation) {
  Remove-Item -Path $oldUnzipLocation -Recurse -Force -ErrorAction SilentlyContinue
}

# Set new install location to ChocolateyInstall\lib\Claude
$unzipLocation = [System.IO.Path]::Combine($env:ChocolateyInstall, "lib", $folderName)

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $unzipLocation
  fileType       = 'EXE' 
  url            = 'https://storage.googleapis.com/osprey-downloads-c02f6a0d-347c-492b-a752-3e0651722e97/nest-win-x64/Claude-Setup-x64.exe'
  softwareName   = 'Claude*' 
  checksum       = '07F100420CE6D0400A41AD4DA9683BF007DD82B29A6827A09CD5B6067EDFD966'
  checksumType   = 'sha256'
  silentArgs     = '/S /VERYSILENT /SUPPRESSMSGBOXES /norestart /quiet /qn /norestart /l*v'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs