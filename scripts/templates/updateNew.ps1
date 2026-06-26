[CmdletBinding()]
param ()

$ErrorActionPreference = 'Stop'
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

$packageInfo = @{
    PackageName   = "{{PACKAGE_ID}}"
    GitHubRepoUrl = "https://api.github.com/repos/{{GITHUB_REPO}}/releases/latest"
    Alert         = $false
}

UpdateChocolateyPackage @packageInfo
