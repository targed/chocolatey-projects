# Stop Claude processes and services before upgrades or deinstallations
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$helpers = Join-Path $toolsDir 'helpers.ps1'
if (Test-Path $helpers) { . $helpers; Stop-ClaudeComponents }
exit 0