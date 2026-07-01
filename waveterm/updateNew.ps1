$ErrorActionPreference = 'Stop'
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# The Chocolatey-Package-Updater handles parsing GitHub API automatically if you pass GitHubRepoUrl
$packageInfo = @{
    PackageName   = "waveterm"
    FileUrl       = "https://github.com/wavetermdev/waveterm/releases/download/v0.14.5/Wave-win32-x64-0.14.5.msi"
    GitHubRepoUrl = "https://github.com/wavetermdev/waveterm"
    Alert         = $false
}

UpdateChocolateyPackage @packageInfo
