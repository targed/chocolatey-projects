[CmdletBinding()] # Enables -Debug parameter for troubleshooting
param ()


# Set vars to the script and the parent path ($ScriptPath MUST be defined for the UpdateChocolateyPackage function to work)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath


# Gets the latest working version URL
$versionNumber = 7
$lastWorkingVersion = $versionNumber
$lastWorkingUrl = ""


try {
    do {
        $versionNumber++
        $mostUpToDateUrl = "https://updater.grayjay.app/Apps/Grayjay.Desktop/${versionNumber}/Grayjay.Desktop-win-x64-v${versionNumber}.zip"
        $response = Invoke-WebRequest -Uri $mostUpToDateUrl -Method Head -ErrorAction Stop
        Write-Host "$mostUpToDateUrl is valid and reachable (Status Code: $($response.StatusCode))."


        $lastWorkingVersion = $versionNumber
        $lastWorkingUrl = $mostUpToDateUrl
    }
    while ($response.StatusCode -ge 200 -and $response.StatusCode -lt 300)
}
catch {
    Write-Host "The URL is not reachable or encountered an error: $($_.Exception.Message)"
}


# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')


# Create a hash table to store package information
$packageInfo = @{
    PackageName = "Grayjay"
    # FileUrl     = "https://updater.grayjay.app/Apps/Grayjay.Desktop/Grayjay.Desktop-win-x64.zip"
    FileUrl     = "https://updater.grayjay.app/Apps/Grayjay.Desktop/$lastWorkingVersion/Grayjay.Desktop-win-x64-v$lastWorkingVersion.zip"
    Alert       = $true
}


# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo


# echo $packageInfo.FileUrl