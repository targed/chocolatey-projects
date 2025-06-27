# Set vars to the script and the parent path ($ScriptPath MUST be defined for the UpdateChocolateyPackage function to work)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# Create a hash table to store package information
$packageInfo = @{
    PackageName   = "jan"
    # FileUrl       = "https://github.com/menloresearch/jan/releases/download/v{VERSION}/jan-win-x64-{VERSION}.exe"
    FileUrl       = "https://github.com/menloresearch/jan/releases/download/v{VERSION}/Jan_{VERSION}_x64-setup.exe"
    GitHubRepoUrl = "https://github.com/menloresearch/jan"
    Alert         = $true # Or $false, depending on preference for notifications
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo