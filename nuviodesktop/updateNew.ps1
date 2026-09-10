$ErrorActionPreference = 'Stop'
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# The Chocolatey-Package-Updater handles parsing GitHub API automatically if you pass GitHubRepoUrl
$packageInfo = @{
    PackageName       = "nuviodesktop"
    FileUrl           = "https://github.com/NuvioMedia/NuvioDesktop/releases/download/{VERSION}/Nuvio-Windows-x64-{VERSION}.msi"
    GitHubRepoUrl     = "https://github.com/NuvioMedia/NuvioDesktop"
    IncludePrerelease = $true
    IgnoreVersion     = "0.1.23-alpha" # Pinned to 0.1.13-alpha while Chocolatey moderation review is in progress
    Alert             = $false
}

UpdateChocolateyPackage @packageInfo
