# Set vars to the script and the parent path ($ScriptPath MUST be defined for the UpdateChocolateyPackage function to work)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# Create a hash table to store package information
$packageInfo = @{
    PackageName   = "Cursor"
    FileUrl       = "https://anysphere-binaries.s3.us-east-1.amazonaws.com/production/ae378be9dc2f5f1a6a1a220c6e25f9f03c8d4e19/win32/x64/user-setup/CursorUserSetup-x64-0.46.11.exe"
    Alert         = $true
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo