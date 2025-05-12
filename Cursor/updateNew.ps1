# Set vars to the script and the parent path ($ScriptPath MUST be defined for the UpdateChocolateyPackage function to work)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

$downloadPage = Invoke-WebRequest -Uri "https://www.cursor.com/api/download?platform=win32-x64-user&releaseTrack=stable" | ConvertFrom-Json
$jsonObject = ($downloadPage.downloadUrl)

# Create a hash table to store package information
$packageInfo = @{
    PackageName = "Cursor"
    FileUrl     = $jsonObject
    Alert       = $false
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo