# Set vars to the script and the parent path ($ScriptPath MUST be defined for the UpdateChocolateyPackage function to work)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# Fetch the download link from the website
$downloadPage = Invoke-WebRequest -Uri "https://lmstudio.ai" -UseBasicParsing
$downloadLink = ($downloadPage.Links | Where-Object { $_.href -like "*LM-Studio-*-x64.exe" }).href[0]

# If the link is relative, make it absolute
if ($downloadLink -notlike "http*") {
    $downloadLink = "https://lmstudio.ai" + $downloadLink
}

Write-Host "Attempting to download from: $downloadLink"

# Try downloading the file first to verify it works
$tempFile = Join-Path $env:TEMP "LM-Studio-temp.exe"
try {
    Invoke-WebRequest -Uri $downloadLink -OutFile $tempFile -UseBasicParsing
    $fileSize = (Get-Item $tempFile).Length / 1MB
    Write-Host "Successfully downloaded file. Size: $fileSize MB"
    
    # Now use the packageInfo with the verified download link
    # Using exact package name without wildcards
    $packageInfo = @{
        PackageName          = "LMStudio"  # Changed from "LM-Studio*" to "lm-studio"
        FileUrl              = $downloadLink
        Alert                = $false
        # Add a custom temp file path to avoid issues with wildcards
        FileDownloadTempPath = Join-Path $env:TEMP "LM-Studio_setup_temp.exe"
    }
    
    # Call the UpdateChocolateyPackage function
    UpdateChocolateyPackage @packageInfo
}
catch {
    Write-Error "Failed to download file: $_"
}
finally {
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force
    }
}