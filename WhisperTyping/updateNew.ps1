# Set vars to the script and the parent path ($ScriptPath MUST be defined for the UpdateChocolateyPackage function to work)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# $downloadPage = Invoke-WebRequest -Uri "https://download.whispertyping.com/whispertypinginstaller.exe" | ConvertFrom-Json
# $jsonObject = ($downloadPage.downloadUrl)

# Create a hash table to store package information
$packageInfo = @{
    PackageName = "WhisperTyping"
    FileUrl     = "https://download.whispertyping.com/whispertypinginstaller.exe"
    Alert       = $false
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo