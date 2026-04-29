# Set vars to the script and the parent path ($ScriptPath MUST be defined for the UpdateChocolateyPackage function to work)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# Get User Installer URL
$downloadPageUser = Invoke-WebRequest -Uri "https://www.cursor.com/api/download?platform=win32-x64-user&releaseTrack=stable" | ConvertFrom-Json
$urlUser = ($downloadPageUser.downloadUrl)

# Get System Installer URL
$downloadPageSystem = Invoke-WebRequest -Uri "https://cursor.com/api/download?platform=win32-x64&releaseTrack=stable" | ConvertFrom-Json
$urlSystem = ($downloadPageSystem.downloadUrl)

# Create a hash table to store package information
$packageInfo = @{
    PackageName = "Cursor"
    FileUrl     = $urlUser
    FileUrl64   = $urlSystem
    Alert       = $false
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo