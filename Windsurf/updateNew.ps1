# Set vars to the script and the parent path ($ScriptPath MUST be defined for the UpdateChocolateyPackage function to work)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# Fetch the download link from the website
$downloadPage = Invoke-WebRequest -Uri "https://windsurf-stable.codeium.com/api/update/win32-x64-user/stable/latesti" | ConvertFrom-Json
$jsonObject = ($downloadPage.url)

# Create a hash table to store package information
$packageInfo = @{
    PackageName = "Windsurf"
    FileUrl     = $jsonObject
    Alert       = $false
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo