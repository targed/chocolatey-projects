[CmdletBinding()] # Enables -Debug parameter for troubleshooting
param ()

# Set vars to the script and the parent path ($ScriptPath MUST be defined for the UpdateChocolateyPackage function to work)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# Create a hash table to store package information
$packageInfo = @{
    PackageName   = "tumblthree"
    FileUrl       = "https://github.com/TumblThreeApp/TumblThree/releases/download/v{VERSION}/TumblThree-v{VERSION}-x64-Application.zip"
    GitHubRepoUrl = "https://github.com/TumblThreeApp/TumblThree"
    Alert         = $true
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo