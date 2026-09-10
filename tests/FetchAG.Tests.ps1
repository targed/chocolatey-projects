BeforeAll {
    $script:repoRoot = Split-Path $PSScriptRoot -Parent
    $script:fetchScript = Join-Path $script:repoRoot 'Antigravity/fetchAG.ps1'
    $script:outputHtml = Join-Path $script:repoRoot 'Antigravity/antigravity_response.html'
}

Describe 'fetchAG.ps1' {
    BeforeEach {
        $script:savedApiKey = $env:SCRAPERAPI_KEY
        if (Test-Path $script:outputHtml) {
            $script:backupBytes = [System.IO.File]::ReadAllBytes($script:outputHtml)
        } else {
            $script:backupBytes = $null
        }
    }

    AfterEach {
        $env:SCRAPERAPI_KEY = $script:savedApiKey
        if ($null -ne $script:backupBytes) {
            [System.IO.File]::WriteAllBytes($script:outputHtml, $script:backupBytes)
        } else {
            Remove-Item -Path $script:outputHtml -Force -ErrorAction SilentlyContinue
        }
    }

    Context 'When SCRAPERAPI_KEY is missing' {
        It 'writes error and exits with code 1' {
            $proc = Start-Process pwsh -ArgumentList '-NoProfile', '-Command', @"
                `$env:SCRAPERAPI_KEY = ''
                & '$($script:fetchScript -replace "'", "''")'
"@ -Wait -PassThru -NoNewWindow -RedirectStandardError "$env:TEMP/fetchag_err.txt"

            $proc.ExitCode | Should -Be 1
            $err = Get-Content "$env:TEMP/fetchag_err.txt" -Raw -ErrorAction SilentlyContinue
            $err | Should -Match 'SCRAPERAPI_KEY environment variable not set'
            Remove-Item "$env:TEMP/fetchag_err.txt" -Force -ErrorAction SilentlyContinue
        }
    }

    Context 'Content sanitization and file writing' {
        It 'sanitizes null bytes and saves output file within script directory' {
            $env:SCRAPERAPI_KEY = 'mock_key'
            $mockContent = "<html><body><a href=`"https://example.com/downloads/Antigravity.exe`">Download</a>`0`0</body></html>"

            Mock Invoke-WebRequest {
                return [PSCustomObject]@{
                    Content = $mockContent
                }
            }

            $result = . $script:fetchScript

            $result | Should -Be 'https://example.com/downloads/Antigravity.exe'
            Test-Path $script:outputHtml | Should -BeTrue

            $savedBytes = [System.IO.File]::ReadAllBytes($script:outputHtml)
            # Verify no null bytes exist in saved file
            ($savedBytes -contains 0) | Should -BeFalse
        }
    }
}
