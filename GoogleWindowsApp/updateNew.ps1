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
    PackageName = "GoogleApp"
    FileUrl     = "https://dl.google.com/tag/s/appguid%3D%7B06A8089E-0B65-445D-B5C4-10B0D1B540F2%7D%26iid%3D%7BC81BC991-C197-1AAD-6717-571B5A938DFA%7D%26lang%3Den%26browser%3D4%26usagestats%3D1%26appname%3DGoogle%2520App%26needsadmin%3DTrue/windows-google-app/GoogleInstaller.exe"
    Alert       = $false
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo
