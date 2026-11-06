$ErrorActionPreference = 'Stop'

# Stop Antigravity and its background language server before an upgrade or uninstall so files are not locked
$processes = @('antigravity', 'language_server')
foreach ($proc in $processes) {
  Get-Process -Name $proc -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}

# Wait briefly for file handles in LocalAppData to release
$deadline = (Get-Date).AddSeconds(5)
while ((Get-Date) -lt $deadline -and (Get-Process -Name 'antigravity', 'language_server' -ErrorAction SilentlyContinue)) {
  Start-Sleep -Milliseconds 500
}
