# Set vars to the script and the parent path ($ScriptPath MUST be defined for the UpdateChocolateyPackage function to work)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# Create a hash table to store package information
$packageInfo = @{
    PackageName   = "nofwl"
    FileUrl       = "https://github.com/lencx/nofwl/releases/download/v{VERSION}/NoFWL_{VERSION}_windows_x86_64.msi"
    GitHubRepoUrl = "https://github.com/lencx/nofwl"
    Alert         = $false
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo