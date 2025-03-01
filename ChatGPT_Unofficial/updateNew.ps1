# Set vars to the script and the parent path ($ScriptPath MUST be defined for the UpdateChocolateyPackage function to work)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# Create a hash table to store package information
$packageInfo = @{
    PackageName   = "ChatGPT"
    FileUrl       = "https://github.com/lencx/ChatGPT/releases/download/v{VERSION}/ChatGPT_{VERSION}_windows_x86_64.msi"
    GitHubRepoUrl = "https://github.com/lencx/ChatGPT"
    Alert         = $true
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo