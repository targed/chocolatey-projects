$ErrorActionPreference = 'Stop'

$process = Get-Process -Name "Google" -ErrorAction SilentlyContinue
if ($process) {
    Start-Sleep -Seconds 10  # Give it a few seconds to fully initialize
    Write-Host "Terminating Google Windows App process..."
    taskkill /F /IM "google.exe" /T
    break
}