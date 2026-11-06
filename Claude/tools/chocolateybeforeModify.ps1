$ErrorActionPreference = 'Stop'

# Stop the MSIX build (app and Cowork service) before an upgrade or uninstall so its files are not in use
$helpers = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) 'helpers.ps1'
if (Test-Path $helpers) {
  . $helpers
  Stop-ClaudeComponents
}
