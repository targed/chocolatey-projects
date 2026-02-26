[CmdletBinding()] # Enables -Debug parameter for troubleshooting
param ()

$ErrorActionPreference = 'Stop'
# Set vars to the script and the parent path ($ScriptPath MUST be defined for the UpdateChocolateyPackage function to work)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# Create a hash table to store package information
$packageInfo = @{
    PackageName = "claude"
    # FileUrl     = "https://storage.googleapis.com/osprey-downloads-c02f6a0d-347c-492b-a752-3e0651722e97/nest-win-x64/Claude-Setup-x64.exe"
    # FileUrl     = "https://claude.ai/api/desktop/win32/x64/exe/latest/redirect"
    FileUrl     = "https://downloads.claude.ai/releases/win32/x64/1.1.1520/Claude-48ced7a78a74c4c1b03d1dab181d1b0dc21d8fc8.exe"
    Alert       = $false
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo
