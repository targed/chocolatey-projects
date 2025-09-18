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
    PackageName = "grass"
    FileUrl     = "https://grass.osgeo.org/grass84/binary/mswindows/native/WinGRASS-8.4.1-1-Setup.exe"
    Alert       = $false
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo
