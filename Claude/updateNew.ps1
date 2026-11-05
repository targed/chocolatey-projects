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

# The MSIX and the ARM64 builds of the same release sit beside the x64 .exe (same hash in the file name, other folder or extension).
# Set their URLs and SHA-256 in the install script before UpdateChocolateyPackage packs the nupkg.
if ($fileUrl -notmatch '/x64/.+\.exe$') {
    throw "Expected an x64 .exe download URL, got: $fileUrl"
}
$installScript = Join-Path $ScriptPath 'tools\chocolateyinstall.ps1'
$installContent = Get-Content $installScript -Raw -Encoding UTF8
$extraBuilds = @(
    @{ Source = 'msixSource';      Sha = 'msixSha256';      Url = ($fileUrl -replace '\.exe$', '.msix') }
    @{ Source = 'msixSourceArm64'; Sha = 'msixSha256Arm64'; Url = ($fileUrl -replace '/x64/', '/arm64/' -replace '\.exe$', '.msix') }
    @{ Source = 'exeSourceArm64';  Sha = 'exeSha256Arm64';  Url = ($fileUrl -replace '/x64/', '/arm64/') }
)
foreach ($build in $extraBuilds) {
    $current = [regex]::Match($installContent, "(?m)^\`$$($build.Source)\s*=\s*'([^']*)'").Groups[1].Value
    $currentSha = [regex]::Match($installContent, "(?m)^\`$$($build.Sha)\s*=\s*'([^']*)'").Groups[1].Value
    if ($current -eq $build.Url -and $currentSha) { continue }
    Write-Host "Hashing $($build.Url)"
    $tempFile = Join-Path ([System.IO.Path]::GetTempPath()) 'claude-update.bin'
    curl.exe --fail -sSL -A $userAgent -o $tempFile $build.Url
    if ($LASTEXITCODE -ne 0) {
        throw "Could not download $($build.Url)"
    }
    $hash = (Get-FileHash -Path $tempFile -Algorithm SHA256).Hash.ToLower()
    Remove-Item $tempFile -Force
    $newUrl = $build.Url
    $installContent = [regex]::Replace($installContent, "(?m)^(\`$$($build.Source)\s*=\s*)'[^']*'", { param($m) "$($m.Groups[1].Value)'$newUrl'" })
    $installContent = [regex]::Replace($installContent, "(?m)^(\`$$($build.Sha)\s*=\s*)'[^']*'", { param($m) "$($m.Groups[1].Value)'$hash'" })
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
