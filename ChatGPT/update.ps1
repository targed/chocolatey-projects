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
    $domain = 'https://github.com'
    $releases = "$domain/lencx/ChatGPT/releases/"
    $pattern = "/v(\d+\.\d+\.\d+)/"
    $download_page = Invoke-WebRequest -Uri $releases -UseBasicParsing #1
    $re = '\.msi$'
    $url = $download_page.links | Where-Object href -match $re | Select-Object -First 1 -expand href
    $url = $domain + $url

    if ($url -match $pattern) {
        $version = $Matches[1]
        Write-Host "Version: $version"
    } else {
        Write-Host "No version found in URL."
    }

    return @{ Version = $version; URL32 = $url }
}

try {
    update -ChecksumFor 32
} catch {
    $ignore = 'Unable to connect to the remote server'
    if ($_ -match $ignore) { Write-Host $ignore; 'ignore' }  else { throw $_ }
}