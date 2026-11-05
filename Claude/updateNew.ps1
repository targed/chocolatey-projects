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

# The MSIX of the same release sits beside the .exe (same folder and hash, other extension).
# Set its URL and SHA-256 in the install script before UpdateChocolateyPackage packs the nupkg.
if ($fileUrl -notmatch '\.exe$') {
    throw "Expected an .exe download URL, got: $fileUrl"
}
$msixUrlNew = $fileUrl -replace '\.exe$', '.msix'
$installScript = Join-Path $ScriptPath 'tools\chocolateyinstall.ps1'
$installContent = Get-Content $installScript -Raw -Encoding UTF8
if ($installContent -notmatch [regex]::Escape("'$msixUrlNew'")) {
    Write-Host "Hashing the MSIX: $msixUrlNew"
    $msixTemp = Join-Path ([System.IO.Path]::GetTempPath()) 'claude-update.msix'
    curl.exe --fail -sSL -A $userAgent -o $msixTemp $msixUrlNew
    if ($LASTEXITCODE -ne 0) {
        throw "Could not download the MSIX from $msixUrlNew"
    }
    $msixHash = (Get-FileHash -Path $msixTemp -Algorithm SHA256).Hash.ToLower()
    Remove-Item $msixTemp -Force
    $installContent = [regex]::Replace($installContent, "(?m)^(\`$msixSource\s*=\s*)'[^']*'", { param($m) "$($m.Groups[1].Value)'$msixUrlNew'" })
    $installContent = [regex]::Replace($installContent, "(?m)^(\`$msixSha256\s*=\s*)'[^']*'", { param($m) "$($m.Groups[1].Value)'$msixHash'" })
    [System.IO.File]::WriteAllText($installScript, $installContent, (New-Object System.Text.UTF8Encoding $true))
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
