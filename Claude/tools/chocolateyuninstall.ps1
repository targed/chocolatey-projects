$ErrorActionPreference = 'Stop'

$folderName = "AnthropicClaude"

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$shortcutPath = "$env:USERPROFILE\Desktop\Claude.lnk"

# Remove the extracted files
$unzipLocation = [System.IO.Path]::Combine($env:ChocolateyInstall, "lib", $folderName)
if (Test-Path $unzipLocation) {
    Remove-Item $unzipLocation -Recurse -Force -ErrorAction SilentlyContinue
}

# Remove Claude directory in old location if it exists (AppData/Local/)
$oldUnzipLocation = Join-Path ([Environment]::GetFolderPath("LocalApplicationData")) $folderName
if (Test-Path $oldUnzipLocation) {
    Remove-Item -Path $oldUnzipLocation -Recurse -Force -ErrorAction SilentlyContinue
}

# Remove the desktop shortcut
if (Test-Path $shortcutPath) {
    Remove-Item $shortcutPath -Force
}

# Remove the extracted files
if (Test-Path $toolsDir) {
    Remove-Item $toolsDir -Recurse -Force
}
