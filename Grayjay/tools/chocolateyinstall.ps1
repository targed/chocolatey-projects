$ErrorActionPreference = 'Stop'
$VerbosePreference = 'SilentlyContinue'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$checksum = '63C3D22842D41A9934EA034EDE04CB994B861D5AC7397CEDE9D60DC5891D5A4E'

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'EXE'
  url            = 'https://updater.grayjay.app/Apps/Grayjay.Desktop/7/Grayjay.Desktop-win-x64-v7.zip'
  softwareName   = 'Grayjay*'
  checksum       = $checksum
  checksumType   = 'sha256'
  
  silentArgs     = '/S'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyZipPackage @packageArgs

# Set full permissions on all extracted files to fix execution issues
$extractedPath = "$($packageArgs.unzipLocation)\Grayjay.Desktop-win-x64-v7"
if (Test-Path $extractedPath) {
  Write-Host "Setting full permissions on Grayjay files..."
  try {
    # Grant full control to Users group on all files and folders
    $acl = Get-Acl $extractedPath
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Users", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.SetAccessRule($accessRule)
    Set-Acl -Path $extractedPath -AclObject $acl
        
    # Recursively apply permissions to all files and subdirectories
    Get-ChildItem -Path $extractedPath -Recurse | ForEach-Object {
      try {
        $itemAcl = Get-Acl $_.FullName
        $itemAcl.SetAccessRule($accessRule)
        Set-Acl -Path $_.FullName -AclObject $itemAcl
      }
      catch {
        Write-Warning "Failed to set permissions on: $($_.FullName)"
      }
    }
    Write-Host "Permissions updated successfully."
  }
  catch {
    Write-Warning "Failed to update permissions: $($_.Exception.Message)"
  }
}

Install-ChocolateyShortcut -shortcutFilePath "$env:USERPROFILE\Desktop\Grayjay.lnk" -targetPath "$($packageArgs.unzipLocation)\Grayjay.Desktop-win-x64-v7\Grayjay.exe" -workingDirectory "$($packageArgs.unzipLocation)\Grayjay.Desktop-win-x64-v7"

# Set "Run as Administrator" flag on the shortcut
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut("$env:USERPROFILE\Desktop\Grayjay.lnk")
# $bytes = [System.IO.File]::ReadAllBytes("$env:USERPROFILE\Desktop\Grayjay.lnk")
# $bytes[0x15] = $bytes[0x15] -bor 0x20
# [System.IO.File]::WriteAllBytes("$env:USERPROFILE\Desktop\Grayjay.lnk", $bytes)