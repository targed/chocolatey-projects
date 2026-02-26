# PowerShell script to fetch Antigravity download URL using ScraperAPI

# Get API key from environment variable (GitHub secret)
$ApiKey = $env:SCRAPERAPI_KEY
if (-not $ApiKey) {
    Write-Error "SCRAPERAPI_KEY environment variable not set. Please set it as a GitHub secret or environment variable."
    exit 1
}

# Build the ScraperAPI URL
$TargetUrl = "https://antigravity.google/download"
$ScraperUrl = "http://api.scraperapi.com?api_key=$ApiKey&url=$TargetUrl&render=true&wait_for=5000"

Write-Host "Fetching URL: $ScraperUrl"

try {
    # Call ScraperAPI
    $response = Invoke-WebRequest -Uri $ScraperUrl -UseBasicParsing
    $htmlContent = $response.Content
    
    # Save HTML to local file for inspection
    $OutputFile = Join-Path $PSScriptRoot "antigravity_response.html"
    $htmlContent | Out-File -FilePath $OutputFile -Encoding UTF8
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
