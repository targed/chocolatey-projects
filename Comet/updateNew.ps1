# Set vars to the script and the parent path ($ScriptPath MUST be defined for the UpdateChocolateyPackage function to work)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# $downloadPage = Invoke-WebRequest -Uri "https://www.perplexity.ai/rest/browser/download?channel=stable&platform=win_x64&mini=1" | ConvertFrom-Json
# $jsonObject = ($downloadPage.downloadUrl)

# Create a hash table to store package information
$packageInfo = @{
    PackageName = "Comet"
    FileUrl     = 'https://www.perplexity.ai/rest/browser/binaries/windows-installers/18329/comet_installer_latest.exe?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=9d06dad57704bf499ceb71a8730b22e4%2F20251004%2Fauto%2Fs3%2Faws4_request&X-Amz-Date=20251004T223000Z&X-Amz-Expires=300&X-Amz-Signature=f365f6471a1baeed5bde6ffd925ccd243fd0047592e361b913e8d81499433c5e&X-Amz-SignedHeaders=host&x-amz-checksum-mode=ENABLED&x-id=GetObject'
    Alert       = $false
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo