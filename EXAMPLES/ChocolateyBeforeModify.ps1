$ErrorActionPreference = 'Stop'

Get-Process Claude -ErrorAction SilentlyContinue | Stop-Process -ErrorAction Stop
Get-Process Claude-Setup-x64 -ErrorAction SilentlyContinue | Stop-Process -ErrorAction Stop