# Set vars to the script and the parent path ($ScriptPath MUST be defined for the UpdateChocolateyPackage function to work)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

$downloadPage = Invoke-WebRequest -Uri "https://api.whispertyping.com/update?channel=stable" | ConvertFrom-Json
$jsonObject = ($downloadPage.installer)

# Create a hash table to store package information
$packageInfo = @{
    PackageName = "WhisperTyping"
    FileUrl     = $jsonObject
    Alert       = $false
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo