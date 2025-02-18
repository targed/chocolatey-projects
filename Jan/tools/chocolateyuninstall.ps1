$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$shortcutPath = "$env:USERPROFILE\Desktop\TumblThree.lnk"

# Remove the desktop shortcut
if (Test-Path $shortcutPath) {
    Remove-Item $shortcutPath -Force
}

# Remove the extracted files
if (Test-Path $toolsDir) {
    Remove-Item $toolsDir -Recurse -Force
}

