$ErrorActionPreference = 'Stop'
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# The Chocolatey-Package-Updater handles parsing GitHub API automatically if you pass GitHubRepoUrl
$packageInfo = @{
    PackageName   = "{{PACKAGE_ID}}"
    GitHubRepoUrl = "https://github.com/{{GITHUB_REPO}}"
    FileUrl       = "{{DOWNLOAD_URL}}"
    Alert         = $false
}

UpdateChocolateyPackage @packageInfo
