# Set vars to the script and the parent path ($ScriptPath MUST be defined for the UpdateChocolateyPackage function to work)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# $downloadPage = Invoke-WebRequest -Uri "https://www.cursor.com/api/download?platform=win32-x64-user&releaseTrack=stable" | ConvertFrom-Json
# $jsonObject = ($downloadPage.downloadUrl)

# Create a hash table to store package information
$packageInfo = @{
    PackageName = "Antigravity"
    FileUrl     = "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.11.2-6251250307170304/windows-x64/Antigravity.exe"
    Alert       = $false
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo