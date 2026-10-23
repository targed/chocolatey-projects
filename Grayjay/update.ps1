import-module au

function global:au_SearchReplace {
    @{
        "tools\chocolateyInstall.ps1" = @{
            "(?i)(^\s*url\s*=\s*)('.*')"      = "`$1'$($Latest.URL32)'"
            "(?i)(^\s*checksum\s*=\s*)('.*')" = "`$1'$($Latest.Checksum32)'"
        }
    }
}

function global:au_GetLatest {
    $versionNumber = 7
    $lastWorkingVersion = $versionNumber
    $lastWorkingUrl = ""

    try {
        do {
            $versionNumber++
            $mostUpToDateUrl = "https://updater.grayjay.app/Apps/Grayjay.Desktop/${versionNumber}/Grayjay.Desktop-win-x64-v${versionNumber}.zip"
            $response = Invoke-WebRequest -Uri $mostUpToDateUrl -UseBasicParsing -Method Head -ErrorAction Stop
            $lastWorkingVersion = $versionNumber
            $lastWorkingUrl = $mostUpToDateUrl
        }
        while ($response.StatusCode -ge 200 -and $response.StatusCode -lt 300)
    }
    catch {
        # Reached the end of available versions
    }

    if (-not $lastWorkingUrl) {
        Write-Host "No version found."
        return $null
    }

    Write-Host "Version: $lastWorkingVersion"
    return @{ Version = $lastWorkingVersion; URL32 = $lastWorkingUrl }
}

try {
    update -ChecksumFor 32
}
catch {
    $ignore = 'Unable to connect to the remote server'
    if ($_ -match $ignore) { Write-Host $ignore; 'ignore' }  else { throw $_ }
}