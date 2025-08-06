$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$shortcutPath = "$env:USERPROFILE\Desktop\Grayjay.lnk"
$startMenuShortcutPath = "$env:PROGRAMDATA\Microsoft\Windows\Start Menu\Programs\Grayjay.lnk"
$appDataPath = "$env:APPDATA\Grayjay"

$pp = Get-PackageParameters

# Remove the desktop shortcut
if (Test-Path $shortcutPath) {
    Remove-Item $shortcutPath -Force
}

# Remove the start menu shortcut
if (Test-Path $startMenuShortcutPath) {
    Remove-Item $startMenuShortcutPath -Force
}

# Remove the extracted files
if (Test-Path $toolsDir) {
    Remove-Item $toolsDir -Recurse -Force
}

# Remove the data from the AppData directory located in AppData\Roaming
if ($pp.RemoveAppData) {
    Write-Host "Removing AppData directory..."
    if (Test-Path $appDataPath) {
        Remove-Item $appDataPath -Recurse -Force
        Write-Host "AppData directory removed."
    }
}
