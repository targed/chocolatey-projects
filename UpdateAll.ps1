# Remember location
Push-Location

# Change to script directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $scriptPath

# Update packages
.\Antigravity\updateNew.ps1
.\ChatGPT_Unofficial\updateNew.ps1
.\Claude\updateNew.ps1
.\Cursor\updateNew.ps1
.\LM_Studio\updateNew.ps1
.\NoFWL\updateNew.ps1
.\TumblThree\updateNew.ps1

# Return
Pop-Location

# Set-ExecutionPolicy Bypass -Scope CurrentUser