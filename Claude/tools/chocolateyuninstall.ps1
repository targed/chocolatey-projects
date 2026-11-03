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
