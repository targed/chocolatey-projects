[CmdletBinding()]
param (
    [switch]$debug = $false
)

$ErrorActionPreference = 'Stop'
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# The Chocolatey-Package-Updater handles parsing GitHub API automatically if you pass GitHubRepoUrl
$packageInfo = @{
    PackageName   = "{{PACKAGE_ID}}"
    GitHubRepoUrl = "https://api.github.com/repos/{{GITHUB_REPO}}"
    Alert         = $false
}

UpdateChocolateyPackage @packageInfo
