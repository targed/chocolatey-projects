# PowerShell script to fetch Antigravity download URL using ScraperAPI

# Enforce TLS 1.2 and TLS 1.3 for secure server certificate validation
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls13

# Get API key from environment variable (GitHub secret)
$ApiKey = $env:SCRAPERAPI_KEY
if (-not $ApiKey) {
    Write-Error "SCRAPERAPI_KEY environment variable not set. Please set it as a GitHub secret or environment variable."
    exit 1
}

# Build the ScraperAPI URL
$TargetUrl = "https://antigravity.google/download"
$ScraperUrl = "https://api.scraperapi.com?api_key=$ApiKey&url=$TargetUrl&render=true&wait_for=5000"

Write-Host "Fetching URL: $ScraperUrl"

try {
    # Call ScraperAPI
    $iwrParams = @{
        Uri        = $ScraperUrl
        TimeoutSec = 30
    }
    # Only supply -UseBasicParsing on Windows PowerShell 5.1 (non-Core) where required to prevent IE DOM initialization
    if ($PSVersionTable.PSEdition -ne 'Core') {
        $iwrParams['UseBasicParsing'] = $true
    }
    $response = Invoke-WebRequest @iwrParams
    $htmlContent = [string]$response.Content
    
    # Strictly validate and bound output file path within script directory to prevent arbitrary writes
    $canonicalRoot = [System.IO.Path]::GetFullPath($PSScriptRoot)
    $outputFileName = "antigravity_response.html"
    $OutputFile = [System.IO.Path]::GetFullPath((Join-Path $canonicalRoot $outputFileName))
    $expectedPrefix = $canonicalRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar

    if (-not $OutputFile.StartsWith($expectedPrefix, [System.StringComparison]::OrdinalIgnoreCase) -or (Split-Path -Leaf $OutputFile) -ne $outputFileName) {
        throw "Invalid output file path resolved: '$OutputFile'"
    }

    # Sanitize content: strip null bytes and invalid control characters to prevent file corruption
    $sanitizedHtml = $htmlContent -replace "[\x00]", ""

    # Save sanitized HTML to local file for inspection
    [System.IO.File]::WriteAllText($OutputFile, $sanitizedHtml, [System.Text.Encoding]::UTF8)
    Write-Host "HTML saved to: $OutputFile"
    
    # Parse the HTML to extract download URL
    # Look for Antigravity.exe download link
    if ($htmlContent -match 'href="([^"]*Antigravity\.exe[^"]*)"') {
        $downloadUrl = $Matches[1]
        Write-Host "`nFound Antigravity.exe URL:"
        Write-Host $downloadUrl
        
        # Return the URL so it can be captured by the calling script
        return $downloadUrl
    }
    # Also try to find any .exe download links
    elseif ($htmlContent -match 'href="(https?://[^"]*\.exe)"') {
        $downloadUrl = $Matches[1]
        Write-Host "`nFound .exe URL:"
        Write-Host $downloadUrl
        return $downloadUrl
    }
    # Try alternative pattern - look in the HTML for download URLs
    elseif ($htmlContent -match '(https?://edgedl\.me\.gvt1\.com/[^"''<>\s]+Antigravity\.exe)') {
        $downloadUrl = $Matches[1]
        Write-Host "`nFound Antigravity.exe URL (alternative pattern):"
        Write-Host $downloadUrl
        return $downloadUrl
    }
    else {
        Write-Warning "Could not find Antigravity.exe download URL in the HTML response."
        Write-Host "`nSearching for any download-related URLs..."
        
        # Show all URLs found in the page for debugging
        $allUrls = [regex]::Matches($htmlContent, 'href="([^"]+)"') | ForEach-Object { $_.Groups[1].Value }
        $downloadUrls = $allUrls | Where-Object { $_ -match '\.(exe|msi|dmg|pkg)' }
        
        if ($downloadUrls) {
            Write-Host "Found these download URLs:"
            $downloadUrls | ForEach-Object { Write-Host "  $_" }
        }
        else {
            Write-Host "No download URLs found. Check the saved HTML file: $OutputFile"
        }
        
        return $null
    }
}
catch {
    Write-Error "Failed to fetch URL: $_"
    exit 1
}
