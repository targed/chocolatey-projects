function Stop-ClaudeComponents {
  # msix package path pattern with publisher id
  $pattern = '*\WindowsApps\Claude_*__pzs8sxrjxfjjc\*'

  function Stop-ClaudeProcesses {
    Get-CimInstance Win32_Process | Where-Object { $_.ExecutablePath -like $pattern } | ForEach-Object {
        Write-Host "Stop process $($_.Name) (PID $($_.ProcessId))"
        Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
    }
  }
  Stop-ClaudeProcesses

  # Stop Claude services
  Get-CimInstance Win32_Service | Where-Object { $_.PathName -like $pattern -and $_.State -ne 'Stopped' } | ForEach-Object {
    Write-Host "Stop service $($_.Name)"
    Stop-Service -Name $_.Name -Force -ErrorAction SilentlyContinue
  }

  Start-Sleep -Seconds 2
  Stop-ClaudeProcesses
}