$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$shortcutPath = "$env:USERPROFILE\Desktop\WhisperTyping.lnk"
$startMenuShortcutPath = "$env:PROGRAMDATA\Microsoft\Windows\Start Menu\Programs\WhisperTyping.lnk"

# Remove the desktop shortcut
if (Test-Path $shortcutPath) {
    Remove-Item $shortcutPath -Force
}

# Remove the start menu shortcut
if (Test-Path $startMenuShortcutPath) {
    Remove-Item $startMenuShortcutPath -Force
}
