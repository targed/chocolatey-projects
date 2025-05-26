param(
    [Parameter(Mandatory=$true)]
    [string]$PackageId,

    [Parameter(Mandatory=$true)]
    [string]$PackageVersion
)

$ErrorActionPreference = 'SilentlyContinue' # Continue on non-terminating errors for Invoke-WebRequest
$OutputEncoding = [System.Text.Encoding]::UTF8 # Ensure consistent output encoding

$url = "https://community.chocolatey.org/packages/$PackageId/$PackageVersion"
$logDir = Join-Path $PSScriptRoot ".." "logs" # Place logs dir one level up from scripts, in repo root
$logFile = Join-Path $logDir "pushed-versions.log"

# Ensure logs directory exists
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

# Write-Host "Checking Chocolatey URL: $url"

try {
    $response = Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 20 # Added timeout
    
    # Check for HTTP status codes that indicate the page exists
    # 200 (OK), 201 (Created), 202 (Accepted) are good indicators.
    # Others like 3xx (Redirection) might also mean it exists in some form.
    # For simplicity, we'll primarily check for 200.
    if ($response.StatusCode -eq 200) {
        Write-Host "Package version $PackageId/$PackageVersion found on Chocolatey.org (Status $($response.StatusCode))."
        Write-Output "SKIP_PUSH"
        exit 0
    } else {
        # For other status codes, it's less certain.
        # It might be a temporary issue, or the package truly isn't there.
        # To be safe and avoid blocking pushes due to transient site issues,
        # we might lean towards proceeding if not a clear "found" or "access denied".
        Write-Host "Package version $PackageId/$PackageVersion not definitively found (Status $($response.StatusCode)). Checking local log."
    }
} catch {
    # Handle exceptions (e.g., 404 Not Found, network errors, timeouts)
    $exceptionDetails = $_.Exception
    Write-Warning "Error checking URL $url`: $($exceptionDetails.Message)"
    if ($exceptionDetails.Response -ne $null) {
        Write-Warning "HTTP Status Code from exception: $($exceptionDetails.Response.StatusCode)"
        if ($exceptionDetails.Response.StatusCode -eq 404) {
            Write-Host "Package version $PackageId/$PackageVersion not found on Chocolatey.org (404)."
            # Proceed to check local log
        } else {
            Write-Host "Non-404 error during web request. Checking local log as a precaution."
            # Proceed to check local log
        }
    } else {
        Write-Host "No HTTP response in exception (e.g., DNS error, timeout). Checking local log."
        # Proceed to check local log
    }
}

# Secondary check: Local log file (if URL check didn't result in SKIP_PUSH)
# This log helps prevent re-pushes if a push was successful but the website hasn't updated yet,
# or if there were issues with the URL check.
if (Test-Path $logFile) {
    $pushedEntry = "$PackageId/$PackageVersion"
    $logContent = Get-Content $logFile -Raw # Read as single string for easier matching
    if ($logContent -match [regex]::Escape($pushedEntry)) {
        Write-Host "Package version $PackageId/$PackageVersion found in local push log ($logFile)."
        Write-Output "SKIP_PUSH"
        exit 0
    }
}

Write-Host "Package version $PackageId/$PackageVersion not found on Chocolatey.org or in local log. Proceeding with push."
Write-Output "PROCEED_WITH_PUSH"
exit 0
