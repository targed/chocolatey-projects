$ErrorActionPreference = 'Stop'

$folderName = "AnthropicClaude"

# Validate $folderName strictly: must be non-empty alphanumeric with optional underscores or dashes
if ([string]::IsNullOrWhiteSpace($folderName) -or $folderName -notmatch '^[a-zA-Z0-9_\-]+$') {
    throw "Invalid folder name specified: '$folderName'"
}

$shortcutPath = "$env:USERPROFILE\Desktop\Claude.lnk"

# Remove the extracted files from Chocolatey lib directory
if (-not [string]::IsNullOrWhiteSpace($env:ChocolateyInstall)) {
    $chocoLibDir = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($env:ChocolateyInstall, "lib"))
    $unzipLocation = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($chocoLibDir, $folderName))

    # Ensure $unzipLocation is strictly a child directory inside $chocoLibDir and matches $folderName
    $expectedLibPrefix = $chocoLibDir.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    if ($unzipLocation.StartsWith($expectedLibPrefix, [System.StringComparison]::OrdinalIgnoreCase) -and 
        (Split-Path -Leaf $unzipLocation) -eq $folderName -and 
        (Test-Path $unzipLocation)) {
        Remove-Item $unzipLocation -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Remove Claude directory in old location if it exists (AppData/Local/AnthropicClaude)
$localAppData = [Environment]::GetFolderPath("LocalApplicationData")
if (-not [string]::IsNullOrWhiteSpace($localAppData)) {
    $localAppDataDir = [System.IO.Path]::GetFullPath($localAppData)
    $oldUnzipLocation = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($localAppDataDir, $folderName))

    # Ensure $oldUnzipLocation is strictly a child directory inside $localAppData and matches $folderName
    $expectedLocalAppPrefix = $localAppDataDir.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    if ($oldUnzipLocation.StartsWith($expectedLocalAppPrefix, [System.StringComparison]::OrdinalIgnoreCase) -and 
        (Split-Path -Leaf $oldUnzipLocation) -eq $folderName -and 
        (Test-Path $oldUnzipLocation)) {
        Remove-Item -Path $oldUnzipLocation -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Remove the desktop shortcut
if (-not [string]::IsNullOrWhiteSpace($shortcutPath) -and $shortcutPath.EndsWith('.lnk') -and (Test-Path $shortcutPath)) {
    Remove-Item $shortcutPath -Force
}

# Remove package tools directory only if it is inside the Chocolatey lib folder
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
if (-not [string]::IsNullOrWhiteSpace($env:ChocolateyInstall) -and -not [string]::IsNullOrWhiteSpace($toolsDir)) {
    $resolvedTools = [System.IO.Path]::GetFullPath($toolsDir)
    $chocoLibDir = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($env:ChocolateyInstall, "lib"))
    $expectedLibPrefix = $chocoLibDir.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    if ($resolvedTools.StartsWith($expectedLibPrefix, [System.StringComparison]::OrdinalIgnoreCase) -and (Test-Path $resolvedTools)) {
        Remove-Item $resolvedTools -Recurse -Force -ErrorAction SilentlyContinue
    }
}
