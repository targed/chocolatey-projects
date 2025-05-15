$packageDir = "Claude"
$nupkgFiles = Get-ChildItem -Path "$packageDir/*.nupkg" -ErrorAction SilentlyContinue | 
Where-Object { $_.LastWriteTime -gt (Get-Date).AddHours(-1) }

if ($nupkgFiles.Count -gt 0) {
    Write-Host "Found updated Claude package to push"
  
    foreach ($nupkg in $nupkgFiles) {
        Write-Host "Pushing package: $($nupkg.FullName)"
    
        if ($env:DRY_RUN -ne "true") {
            choco push $nupkg.FullName --source=https://push.chocolatey.org/ --api-key=$env:CHOCO_API_KEY
        }
        else {
            Write-Host "DRY RUN: Would have pushed $($nupkg.FullName) to Chocolatey"
        }
    }
}
else {
    Write-Host "No updated Claude package found to push"
}