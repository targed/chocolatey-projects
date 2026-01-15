[CmdletBinding()] # Enables -Debug parameter for troubleshooting
param ()

$ErrorActionPreference = 'Stop'
# Set vars to the script and the parent path ($ScriptPath MUST be defined for the UpdateChocolateyPackage function to work)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# # Create a hash table to store package information
# $packageInfo = @{
#     PackageName = "cloudcompare"
#     FileUrl     = "https://www.cloudcompare.org/release/CloudCompare_v2.13.2_setup_x64.exe"
#     Alert       = $false
# }

# # Call the UpdateChocolateyPackage function and pass the hash table
# UpdateChocolateyPackage @packageInfo


# Gets the latest working version URL
$majorVersion = 2
$minorVersion = 13
$patchVersion = 1


$versionNumber = 2.13.1
$lastWorkingVersion = $versionNumber
$lastWorkingUrl = ""

$continueSearching = $true
while ($continueSearching -and $majorVersion -lt 10) {
    $versionNumber = "$majorVersion.$minorVersion.$patchVersion"
    $mostUpToDateUrl = "https://www.cloudcompare.org/release/CloudCompare_v${versionNumber}_setup_x64.exe"
    
    try {
        $response = Invoke-WebRequest -Uri $mostUpToDateUrl -Method Head -ErrorAction Stop
        Write-Host "$mostUpToDateUrl is valid and reachable (Status Code: $($response.StatusCode))."
        
        $lastWorkingVersion = $versionNumber
        $lastWorkingUrl = $mostUpToDateUrl
        
        # Increment patch version
        $patchVersion++
        
        # Handle version overflow
        if ($patchVersion -ge 20) {
            $patchVersion = 0
            $minorVersion++
            if ($minorVersion -ge 20) {
                $minorVersion = 0
                $majorVersion++
            }
        }
    }
    catch {
        Write-Host "The URL is not reachable or encountered an error: $($_.Exception.Message)"
        $continueSearching = $false
    }
}


# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')


# Create a hash table to store package information
$packageInfo = @{
    PackageName = "CloudCompare"
    FileUrl     = $lastWorkingUrl
    Alert       = $true
}


# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo


Write-Output $packageInfo.FileUrl