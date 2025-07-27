$ErrorActionPreference = 'Stop'
$VerbosePreference = 'SilentlyContinue'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$checksum = '5E89759E0F5BB6CF5FF621EDFE8A564499AAE2E904F88D14D7841F7BB32B905D'

# Get package parameters
$pp = Get-PackageParameters

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'EXE'
  url            = 'https://updater.grayjay.app/Apps/Grayjay.Desktop/9/Grayjay.Desktop-win-x64-v9.zip'
  softwareName   = 'Grayjay*'
  checksum       = $checksum
  checksumType   = 'sha256'
  
  silentArgs     = '/S'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyZipPackage @packageArgs

# Set full permissions on all extracted files to fix execution issues
$extractedPath = "$($packageArgs.unzipLocation)\Grayjay.Desktop-win-x64-v9"
if (Test-Path $extractedPath) {
  Write-Host "Setting full permissions on Grayjay files..."
  try {
    # Grant full control to Users group - inheritance will apply to all nested files and folders
    $acl = Get-Acl $extractedPath
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Users", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.SetAccessRule($accessRule)
    Set-Acl -Path $extractedPath -AclObject $acl
    Write-Host "Permissions updated successfully."
  }
  catch {
    Write-Warning "Failed to update permissions: $($_.Exception.Message)"
  }

  # Handle portable mode configuration
  if ($pp.NoPortable) {
    Write-Host "Disabling portable mode..."
    
    # Look for common portable marker files and remove them
    $portableMarkers = @(
      "portable",
      "portable.txt", 
      ".portable",
      "Grayjay.portable",
      "PORTABLE"
    )
    
    foreach ($marker in $portableMarkers) {
      $markerPath = Join-Path $extractedPath $marker
      if (Test-Path $markerPath) {
        Remove-Item $markerPath -Force
        Write-Host "Removed portable marker file: $marker"
        break
      }
    }
  }
}

# Create desktop shortcut unless NoShortcut parameter is specified
if (-not $pp.NoShortcut) {
  Install-ChocolateyShortcut -shortcutFilePath "$env:USERPROFILE\Desktop\Grayjay.lnk" -targetPath "$($packageArgs.unzipLocation)\Grayjay.Desktop-win-x64-v9\Grayjay.exe" -workingDirectory "$($packageArgs.unzipLocation)\Grayjay.Desktop-win-x64-v9"
}