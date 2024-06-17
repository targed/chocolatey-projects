# Remember location
Push-Location

# Change to script directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $scriptPath

# Update packages
./ChatGPT/updateNew.ps1
./TumblThree/update.ps1

# Return
Pop-Location