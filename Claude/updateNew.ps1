[CmdletBinding()] # Enables -Debug parameter for troubleshooting
param ()

$ErrorActionPreference = 'Stop'
# Set vars to the script and the parent path ($ScriptPath MUST be defined for the UpdateChocolateyPackage function to work)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

# Resolve the latest download URL from the redirect endpoint using curl.exe to bypass .NET TLS fingerprinting blocks
$redirectUrl = "https://claude.ai/api/desktop/win32/x64/exe/latest/redirect"
Write-Host "Resolving redirect for Claude..."
$userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

$headers = curl.exe -i -A $userAgent -s $redirectUrl
$fileUrl = $null
foreach ($line in $headers) {
    if ($line -match '^location:\s*(.+)$') {
        $fileUrl = $matches[1].Trim()
        break
    }
}

if (-not $fileUrl) {
    throw "Failed to resolve redirect URL for Claude."
}

Write-Host "Resolved URL: $fileUrl"

# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# Create a hash table to store package information
$packageInfo = @{
    PackageName = "claude"
    FileUrl     = $fileUrl
    Alert       = $false
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo
