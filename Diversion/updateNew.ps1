# Set vars to the script and the parent path ($ScriptPath MUST be defined for the UpdateChocolateyPackage function to work)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# Create a hash table to store package information
$packageInfo = @{
    PackageName = "diversion"
    FileUrl     = "https://dv-binaries.s3.us-east-2.amazonaws.com/windows_x86_64/diversion_windows_x86_64.exe"
    Alert       = $false
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo