$ErrorActionPreference = 'Stop'
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# The Chocolatey-Package-Updater handles parsing GitHub API automatically if you pass GitHubRepoUrl
$packageInfo = @{
    PackageName   = "reasonix-desktop"
    FileUrl       = "https://github.com/esengine/DeepSeek-Reasonix/releases/download/{VERSION}/Reasonix-windows-amd64-installer.exe"
    GitHubRepoUrl = "https://github.com/esengine/DeepSeek-Reasonix"
    Alert         = $false
}

UpdateChocolateyPackage @packageInfo
