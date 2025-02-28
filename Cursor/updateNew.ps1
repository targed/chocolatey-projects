# Set vars to the script and the parent path ($ScriptPath MUST be defined for the UpdateChocolateyPackage function to work)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# Create a hash table to store package information
$packageInfo = @{
    PackageName   = "Cursor"
    FileUrl       = "https://anysphere-binaries.s3.us-east-1.amazonaws.com/production/3611c5390c448b242ab97e328493bb8ef7241e61/win32/x64/user-setup/CursorUserSetup-x64-0.46.7.exe"
    Alert         = $true
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo