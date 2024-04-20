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
    $domain = "https://download.cursor.sh/windows/nsis/x64"
    $pattern = "v(\d+\.\d+\.\d+)"
    try {
        $download_page = Invoke-WebRequest -Uri $domain -UseBasicParsing
    }
    catch {
        Write-Host "Failed to retrieve releases page: $_"
        return $null
    }
    $re = '\.zip$'
    $url = $download_page.Links | Where-Object href -match $re | Select-Object -First 1 -ExpandProperty href
    $url = $domain + $url

    if ($url -match $pattern) {
        $version = $Matches[1]
        Write-Host "Version: $version"
    }
    else {
        Write-Host "No version found in URL."
        return $null
    }

    # Placeholder for checksum retrieval or calculation
    $checksum = "YourMethodToGetChecksum"

    return @{ Version = $version; URL32 = $url; Checksum32 = $checksum }
}

try {
    update -ChecksumFor 32
}
catch {
    $ignore = 'Unable to connect to the remote server'
    if ($_ -match $ignore) { Write-Host $ignore; 'ignore' }  else { throw $_ }
}