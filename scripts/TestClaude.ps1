$packageDir = "Claude"
$updatedPackage = $null

if (Test-Path (Join-Path $packageDir "*.nupkg")) {
    Write-Host "Found .nupkg in Claude directory"
            
    # Extract packageId from nuspec file
    $nuspecFile = Get-ChildItem -Path "$packageDir/*.nuspec" | Select-Object -First 1
            
    if ($nuspecFile) {
        [xml]$nuspecContent = Get-Content -Path $nuspecFile.FullName
        $packageId = $nuspecContent.package.metadata.id
              
        if ($packageId) {
            $updatedPackage = [PSCustomObject]@{
                Directory = $packageDir
                PackageId = $packageId
                NupkgFile = (Get-ChildItem -Path "$packageDir/*.nupkg" | Select-Object -First 1).FullName
            }
                
            Write-Host "Updated package found: $packageId"
                
            # Install package by ID
            Write-Host "Installing package: $($updatedPackage.PackageId)"
            choco install $($updatedPackage.PackageId) -y --debug --verbose --source .
                
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Package installation failed: $($updatedPackage.PackageId)"
                exit 1
            }
                
            # Uninstall the package 
            Write-Host "Uninstalling package: $($updatedPackage.PackageId)"
            choco uninstall $($updatedPackage.PackageId) -y
                
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Package uninstallation failed: $($updatedPackage.PackageId)"
                exit 1
            }
        }
        else {
            Write-Warning "Could not extract package ID from nuspec file"
        }
    }
    else {
        Write-Warning "No nuspec file found in Claude directory"
    }
}
else {
    Write-Host "No .nupkg found in Claude directory - no update needed"
}