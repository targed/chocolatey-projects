# Set vars to the script and the parent path ($ScriptPath MUST be defined for the UpdateChocolateyPackage function to work)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# Fetch the latest Antigravity download URL using ScraperAPI
Write-Host "Fetching latest Antigravity download URL..."
$fetchScript = Join-Path $ScriptPath "fetchAG.ps1"
$downloadUrl = & $fetchScript

if (-not $downloadUrl) {
    Write-Error "Failed to fetch Antigravity download URL. Using fallback URL."
    # Fallback to a known URL in case scraping fails
    $downloadUrl = "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.18.4-5780041996042240/windows-x64/Antigravity.exe"
}

Write-Host "`nUsing download URL: $downloadUrl`n"

# Create a hash table to store package information
$packageInfo = @{
    PackageName = "Antigravity"
    FileUrl     = $downloadUrl
    Alert       = $false
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo