# Set vars to the script and the parent path ($ScriptPath MUST be defined for the UpdateChocolateyPackage function to work)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# Fetch the download link from the website
$downloadPage = Invoke-WebRequest -Uri "https://lmstudio.ai"
$downloadLink = ($downloadPage.Links | Where-Object { $_.href -like "*LM-Studio-*-x64.exe" }).href

# Create a hash table to store package information
$packageInfo = @{
    PackageName = "LM-Studio*"
    FileUrl     = $downloadLink
    Alert       = $true
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo