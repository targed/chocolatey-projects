[CmdletBinding()] # Enables -Debug parameter for troubleshooting
param ()

$ErrorActionPreference = 'Stop'
# Set vars to the script and the parent path ($ScriptPath MUST be defined for the UpdateChocolateyPackage function to work)
$ScriptPath = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent (Resolve-Path $MyInvocation.MyCommand.Definition) }
$ParentPath = Split-Path -Parent $ScriptPath

# Candidate redirect endpoints:
# 1. api.anthropic.com is Anthropic's official API backend used by the desktop installer and does not block CI/cloud datacenter IPs
# 2. claude.ai is the web frontend endpoint (fallback)
$endpoints = @(
    "https://api.anthropic.com/api/desktop/win32/x64/exe/latest/redirect",
    "https://claude.ai/api/desktop/win32/x64/exe/latest/redirect"
)

$userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
$fileUrl = $null
$lastErrorDetails = @()

foreach ($redirectUrl in $endpoints) {
    Write-Host "Resolving redirect for Claude via $redirectUrl..."
    $headers = curl.exe -i -L --max-redirs 0 -A $userAgent -s $redirectUrl
    foreach ($line in $headers) {
        if ($line -match '^location:\s*(.+)$') {
            $fileUrl = $matches[1].Trim()
            break
        }
    }
    if ($fileUrl) {
        Write-Host "Successfully resolved download URL: $fileUrl"
        break
    } else {
        $statusLine = ($headers | Select-Object -First 1)
        $lastErrorDetails += "$redirectUrl returned: $statusLine"
        Write-Warning "No redirect location returned from $redirectUrl ($statusLine)"
    }
}

if (-not $fileUrl) {
    throw "Failed to resolve redirect URL for Claude from all candidate endpoints. Details: $($lastErrorDetails -join '; ')"
}

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
