function Stop-ClaudeComponents {
  # Processes and services of the MSIX build run from the package folder in WindowsApps
  $pattern = '*\WindowsApps\Claude_*__pzs8sxrjxfjjc\*'

  Get-CimInstance Win32_Service | Where-Object { $_.PathName -like $pattern -and $_.State -ne 'Stopped' } | ForEach-Object {
    Write-Host "Stopping service $($_.Name)"
    Stop-Service -Name $_.Name -Force -ErrorAction SilentlyContinue
  }

  Get-CimInstance Win32_Process | Where-Object { $_.ExecutablePath -like $pattern } | ForEach-Object {
    Write-Host "Stopping process $($_.Name) (PID $($_.ProcessId))"
    Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
  }

  # Wait for the files to be released
  $deadline = (Get-Date).AddSeconds(15)
  while ((Get-Date) -lt $deadline -and (Get-CimInstance Win32_Process | Where-Object { $_.ExecutablePath -like $pattern })) {
    Start-Sleep -Milliseconds 500
  }
}
