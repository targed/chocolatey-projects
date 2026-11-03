$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# $folderName = "AnthropicClaude"

# # Remove Claude directory in old location if it exists (ProgramData/$USER$)
# $oldUnzipLocation = Join-Path ([Environment]::GetFolderPath("CommonApplicationData")) $folderName
# if (Test-Path $oldUnzipLocation) {
#   Remove-Item -Path $oldUnzipLocation -Recurse -Force -ErrorAction SilentlyContinue
# }

# # Set new install location to ChocolateyInstall\lib\Claude
# $unzipLocation = [System.IO.Path]::Combine($env:ChocolateyInstall, "lib", $folderName)

$pp = Get-PackageParameters
$enableVirtualizationPlatform = if ($pp.ContainsKey("enableVirtualizationPlatform")) { $true } else { $false }


$packageName  = $env:ChocolateyPackageName
$url          = 'https://downloads.claude.ai/releases/win32/x64/4.4212.0/Claude-cbfe3c56d49c49332ad5a9588303c9dbc70a5e7f.msix'
$downloadPath = Join-Path $env:TEMP "$packageName.msix"

$checksum     = '5e7cd0edfe4a5561e6f69b0249757d23de752a74151e016fe81bc939ddc5439e'
$checksumtype = 'sha256'

try {
    Get-ChocolateyWebFile -PackageName $packageName `
                          -FileFullPath $downloadPath `
                          -Url $url `
                          -Checksum $checksum `
                          -ChecksumType $checksumtype
    # Stop Claude processes and services before installation
    . (Join-Path $toolsDir 'helpers.ps1')
    Stop-ClaudeComponents

    Add-AppxProvisionedPackage -Online -PackagePath $downloadPath -SkipLicense -Regions 'all' -LogPath "$($env:TEMP)\$($env:ChocolateyPackageName).$($env:chocolateyPackageVersion).MsixInstall.log"
    Write-Host "Installed Claude MSIX package systemwide!"
    if ($enableVirtualizationPlatform) {
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart
        Write-Host "Virtual Machine Platform is enabled. Windows restart required."
    }
}
catch {
    Write-Error "Error during MSIX-Installation: $_"
    throw $_
}
finally {
    if (Test-Path $downloadPath) {
        Remove-Item -Path $downloadPath -Force
    }
}

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
