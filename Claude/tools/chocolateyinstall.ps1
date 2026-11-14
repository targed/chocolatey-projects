$ErrorActionPreference = 'Stop'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Package parameters:
#   /Legacy                        install the per-user Squirrel installer (.exe) instead of the MSIX (used automatically below Windows 10 2004)
#   /DisableAutoUpdates            MSIX only: set Claude's disableAutoUpdates policy so Chocolatey manages the version
#   /EnableVirtualizationPlatform  MSIX only: enable the Windows Virtual Machine Platform that Cowork needs (restart required)
$pp = Get-PackageParameters

# Chocolatey runs as an emulated x64 process on ARM64 Windows, so PROCESSOR_ARCHITECTURE reports AMD64 there
$isArm64 = $env:PROCESSOR_IDENTIFIER -like 'ARMv*'

# MSIX build of the same release as the .exe below: machine-wide, includes the Cowork service
$msixSource = 'https://downloads.claude.ai/releases/win32/x64/5.11492.5/Claude-1403e2cf44abfb23809c8ae11238d5e9704a41c2.msix'
$msixSha256 = '4625eaa902e05c81d35d247423ae24a2a1c30e60cae9b355c07264998a89e453'
$msixSourceArm64 = 'https://downloads.claude.ai/releases/win32/arm64/5.11492.5/Claude-1403e2cf44abfb23809c8ae11238d5e9704a41c2.msix'
$msixSha256Arm64 = '16acdc98901f03d01c8f0ba219d7570668d949e01654c13cbac3bbd4bd61e3e7'

# Squirrel installer, used with /Legacy
$exeSourceArm64 = 'https://downloads.claude.ai/releases/win32/arm64/5.11492.5/Claude-1403e2cf44abfb23809c8ae11238d5e9704a41c2.exe'
$exeSha256Arm64 = '7e202f77dcfb6819de4d0c727cfba005d6b2d3e28d022ea1b7ddf2bd87975249'
$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'EXE'
  url            = 'https://downloads.claude.ai/releases/win32/x64/5.11492.5/Claude-1403e2cf44abfb23809c8ae11238d5e9704a41c2.exe'
  softwareName   = 'Claude*'
  checksum       = '484FE481263A517FEA20E4CE2F8AD2785FB373226720E5AD1AD5640C0C4FDEF0'
  checksumType   = 'sha256'

  # The installer is Squirrel (Setup.exe), which ignores the NSIS/Inno switches; --silent hides its install window
  silentArgs     = '--silent'
  validExitCodes = @(0, 3010, 1641)
}

# The MSIX needs Windows 10 version 2004 (build 19041) or later and an elevated shell; older builds get the legacy installer
$useLegacy = [bool]$pp.Legacy
if (-not $useLegacy -and [Environment]::OSVersion.Version.Build -lt 19041) {
  Write-Warning 'The Claude MSIX needs Windows 10 version 2004 (build 19041) or later. Falling back to the legacy installer.'
  $useLegacy = $true
}

if ($useLegacy) {
  Write-Warning 'Installing the legacy per-user Claude installer. Cowork needs the default MSIX install.'
  if ($isArm64) {
    $packageArgs.url = $exeSourceArm64
    $packageArgs.checksum = $exeSha256Arm64
  }
  Install-ChocolateyPackage @packageArgs
  return
}

. (Join-Path $toolsDir 'helpers.ps1')

# Done first, so a failure leaves nothing half-installed. Anthropic's command, run only when the feature is off.
$restartNeeded = $false
if ($pp.EnableVirtualizationPlatform) {
  $vmp = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
  if ($vmp.State -eq 'Enabled') {
    Write-Host 'The Windows Virtual Machine Platform is already enabled.'
  } else {
    $result = Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart
    $restartNeeded = [bool]$result.RestartNeeded
    Write-Host 'The Windows Virtual Machine Platform was enabled.'
  }
}

# A leftover per-user install from the /Legacy installer (or an earlier version of this package) would sit beside the MSIX
[array]$squirrel = Get-UninstallRegistryKey -SoftwareName 'Claude*' -WarningAction SilentlyContinue | Where-Object { $_.UninstallString -match 'Update\.exe' }
if ($squirrel.Count -gt 0) {
  Write-Warning 'A per-user Claude installation from the legacy installer was found. It is left in place; uninstall it from Apps & features if you no longer need it.'
}

$source = $msixSource
$sha256 = $msixSha256
if ($isArm64) {
  $source = $msixSourceArm64
  $sha256 = $msixSha256Arm64
}

$downloadDir = Join-Path $env:TEMP "$($env:ChocolateyPackageName).$($env:ChocolateyPackageVersion)"
$msixFile = Join-Path $downloadDir 'Claude.msix'
New-Item -ItemType Directory -Path $downloadDir -Force | Out-Null

try {
  Get-ChocolateyWebFile -PackageName $env:ChocolateyPackageName `
    -FileFullPath $msixFile `
    -Url $source `
    -Checksum $sha256 `
    -ChecksumType 'sha256'

  # The Cowork service and a running Claude hold the files of the installed build
  Stop-ClaudeComponents

  # Stages the package for every user and registers it for the signed-in user
  Add-AppxProvisionedPackage -Online -PackagePath $msixFile -SkipLicense -Regions 'all' `
    -LogPath (Join-Path $downloadDir 'MsixInstall.log') | Out-Null
  Write-Host 'Claude was installed machine-wide (MSIX).'
} finally {
  Remove-Item -Path $downloadDir -Recurse -Force -ErrorAction SilentlyContinue
}

if ($pp.DisableAutoUpdates) {
  $policyKey = 'HKLM:\SOFTWARE\Policies\Claude'
  # New-Item -Force on an existing key would empty it, which would drop any other Claude policies
  if (-not (Test-Path $policyKey)) { New-Item -Path $policyKey | Out-Null }
  Set-ItemProperty -Path $policyKey -Name 'disableAutoUpdates' -Value 1 -Type DWord
  Write-Host 'Claude automatic updates are disabled (HKLM policy); Chocolatey now manages the version.'
}

if ($restartNeeded) {
  Write-Warning 'Restart Windows before using Cowork: the Virtual Machine Platform was just enabled.'
}
