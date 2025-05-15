$packageDir = "Cursor"
# Extract packageVersion from nuspec file
$nuspecFile = Get-ChildItem -Path "$packageDir/*.nuspec" | Select-Object -First 1
    
if ($nuspecFile) {
    [xml]$nuspecContent = Get-Content -Path $nuspecFile.FullName

    $packageId = $nuspecContent.package.metadata.id
    Write-Host "Package ID: $packageId"

    $localPackageVersion = $nuspecContent.package.metadata.version
    Write-Host "Local package version: $localPackageVersion"    # Check if the package version is already in the remote chocolatey repository
    $chocoInfoOutput = choco info $packageId
    # Write-Host "Chocolatey Info Output:"
    # $chocoInfoOutput | ForEach-Object { Write-Host $_ }
    
    # Extract remote version from the choco info output
    $remoteVersionLine = $chocoInfoOutput | Select-String -Pattern "^$packageId\s+([0-9]+\.[0-9]+\.[0-9]+)" | Select-Object -First 1
    
    if ($remoteVersionLine) {
        $remoteVersionMatch = $remoteVersionLine -match "^$packageId\s+([0-9]+\.[0-9]+\.[0-9]+)"
        $remotePackageVersion = $matches[1]
        Write-Host "Remote package version: $remotePackageVersion"
        
        # Compare versions correctly using System.Version for proper semantic versioning comparison
        $localVersion = [System.Version]$localPackageVersion
        $remoteVersion = [System.Version]$remotePackageVersion
        
        if ($localVersion -le $remoteVersion) {
            Write-Host "Local package version $localPackageVersion is not newer than remote version $remotePackageVersion."
            Write-Host "No need to push, exiting."
            exit 0
        }
        else {
            Write-Host "Local package version $localPackageVersion is newer than remote version $remotePackageVersion."
            Write-Host "Continuing with package push..."
        }
    }
    else {
        Write-Host "Could not find remote package version or package does not exist yet."
        Write-Host "Continuing with package push..."
    }
    
    $nupkgFiles = Get-ChildItem -Path "$packageDir/*$localPackageVersion.nupkg" -ErrorAction SilentlyContinue | 
    Where-Object { $_.LastWriteTime -gt (Get-Date).AddHours(-1) }
    if ($nupkgFiles.Count -gt 0) {
        Write-Host "Found updated Cursor package to push"
  
        foreach ($nupkg in $nupkgFiles) {
            Write-Host "Pushing package: $($nupkg.FullName)"
    
            try {
                choco push $nupkg.FullName --source=https://push.chocolatey.org/ --api-key=$env:CHOCO_API_KEY
            }
            catch {
                Write-Warning "Failed to push package: $($nupkg.FullName)"
                exit 0
            }
        }
    }
    else {
        Write-Host "No updated Cursor package found to push"
    }
}