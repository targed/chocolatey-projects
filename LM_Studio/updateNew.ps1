# Set vars to the script and the parent path ($ScriptPath MUST be defined for the UpdateChocolateyPackage function to work)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# Fetch the download link from the website
$downloadPage = Invoke-WebRequest -Uri "https://lmstudio.ai"
$downloadLink = ($downloadPage.Links | Where-Object { $_.href -like "*LM-Studio-*-x64.exe" }).href[0]

# Create a hash table to store package information
$packageInfo = @{
    PackageName = "LM-Studio*"
    FileUrl     = "https://installers.lmstudio.ai/win32/x64/0.3.14-5/LM-Studio-0.3.14-5-x64.exe"
    Alert       = $true
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo