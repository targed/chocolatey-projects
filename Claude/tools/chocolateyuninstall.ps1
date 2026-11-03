$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
. (Join-Path $toolsDir 'helpers.ps1')
Stop-ClaudeComponents

$packageNamePattern = 'Claude_*_pzs8sxrjxfjjc'

Write-Host "Deinstalling Claude ..."
$prov = @(Get-AppxProvisionedPackage -Online | Where-Object PackageName -like $packageNamePattern)
foreach ($p in $prov) {
    Remove-AppxProvisionedPackage -Online -PackageName $p.PackageName -AllUsers
    Write-Host "Provisioning removed: $($p.PackageName)"
}

$registryPath = "HKLM:\SOFTWARE\Policies\Claude"

if (Test-Path $registryPath) {
    try {
        Remove-Item -Path $registryPath -Recurse -Force -ErrorAction Stop
        Write-Host "Removed  registry-path'$registryPath'."
    } catch {
        Write-Warning "Registry path '$registryPath' could not be deleted."
    }

} else {
    Write-Host "Registry path '$registryPath' does not exist. No registry cleanup needed."
}
