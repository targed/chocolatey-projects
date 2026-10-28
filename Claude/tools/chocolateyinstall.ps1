$ErrorActionPreference = 'Continue'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# $folderName = "AnthropicClaude"

# # Remove Claude directory in old location if it exists (ProgramData/$USER$)
# $oldUnzipLocation = Join-Path ([Environment]::GetFolderPath("CommonApplicationData")) $folderName
# if (Test-Path $oldUnzipLocation) {
#   Remove-Item -Path $oldUnzipLocation -Recurse -Force -ErrorAction SilentlyContinue
# }

# # Set new install location to ChocolateyInstall\lib\Claude
# $unzipLocation = [System.IO.Path]::Combine($env:ChocolateyInstall, "lib", $folderName)

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'EXE' 
  url            = 'https://downloads.claude.ai/releases/win32/x64/4.29.0/Claude-2609742292f7dbce2e259e76f53620cac4da9002.exe'
  softwareName   = 'Claude*' 
  checksum       = '669B6C60B1A56028DF49D745D045658F51BE5CF787B7D17792DA632ED0D2EB1C'
  checksumType   = 'sha256'

  # The installer is Squirrel (Setup.exe), which ignores the NSIS/Inno switches; --silent hides its install window
  silentArgs     = '--silent'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs

# Exho where claude-Setup-x64.exe is located
# Write-Host "Claude-Setup-x64.exe is located at: $unzipLocation"
# # ls the dir to see what is in it
# ls $unzipLocation

# Stop-Process -Name Claude-Setup-x64 -Force -ErrorAction SilentlyContinue

# Start-Process -WindowStyle Hidden -FilePath $oldUnzipLocation\Claude-Setup-x64.exe -ArgumentList '/S /VERYSILENT /SUPPRESSMSGBOXES /norestart /quiet /qn /norestart /l*v /SP- $locale'

# Kill the pop-up window that the installer creates without stopping the installation
# $process = Get-Process | Where-Object { $_.MainWindowTitle -eq "Claude" }
# if ($process) {
#   Stop-Process -Id $process.Id
# }
# Stop-Process -Name Claude-Setup-x64 -Force -ErrorAction SilentlyContinue
# Stop-Process -Name Claude -Force -ErrorAction SilentlyContinue

# Download the installer
# $installerPath = Join-Path $env:TEMP 'Claude-Setup-x64.exe'
# Invoke-WebRequest -Uri $packageArgs.url -OutFile $installerPath -UseBasicParsing

# # Run the installer with hidden window style
# $startInfo = New-Object System.Diagnostics.ProcessStartInfo
# $startInfo.FileName = $installerPath
# $startInfo.Arguments = '/S /VERYSILENT /SUPPRESSMSGBOXES /norestart /quiet /qn /norestart /l*v /SP- $locale'
# $startInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
# $process = [System.Diagnostics.Process]::Start($startInfo)
# $process.WaitForExit()

# # Clean up the installer
# Remove-Item -Path $installerPath -Force

#wait for the installer to finish
# $process = Get-Process | Where-Object { $_.MainWindowTitle -eq "Claude" }
# if ($process) {
#   $process.WaitForExit()
#   $process.MainWindowHandle | ForEach-Object { (New-Object -TypeName System.Windows.Forms.Form -Property @{ Visible = $true; TopMost = $true; WindowState = 'Minimized'; Opacity = 0 }).Show() }
# }

# Set the pop-up window that the installer creates to hidden and run in the background
# $process = Get-Process | Where-Object { $_.MainWindowTitle -eq "Claude" }
# if ($process) {
#   $process.MainWindowHandle | ForEach-Object { (New-Object -TypeName System.Windows.Forms.Form -Property @{ Visible = $true; TopMost = $true; WindowState = 'Minimized'; Opacity = 0 }).Show() }
# }
