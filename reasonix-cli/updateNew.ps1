$ErrorActionPreference = 'Stop'
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# The Chocolatey-Package-Updater handles parsing GitHub API automatically if you pass GitHubRepoUrl
$packageInfo = @{
    PackageName   = "reasonix-cli"
    GitHubRepoUrl = "https://github.com/esengine/DeepSeek-Reasonix"
    FileUrl       = "https://github.com/esengine/DeepSeek-Reasonix/releases/download/{VERSION}/reasonix-windows-amd64.zip"
    Alert         = $false
}

UpdateChocolateyPackage @packageInfo
