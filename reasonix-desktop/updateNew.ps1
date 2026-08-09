$ErrorActionPreference = 'Stop'
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# The Chocolatey-Package-Updater handles parsing GitHub API automatically if you pass GitHubRepoUrl
$packageInfo = @{
    PackageName   = "reasonix-desktop"
    GitHubRepoUrl = "https://github.com/esengine/DeepSeek-Reasonix"
    FileUrl       = "https://dl.reasonix.io/desktop-v1.21.4/Reasonix-windows-amd64-installer.exe"
    Alert         = $false
}

UpdateChocolateyPackage @packageInfo
