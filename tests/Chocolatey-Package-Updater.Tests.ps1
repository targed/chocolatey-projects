BeforeAll {
    $script:repoRoot = Split-Path $PSScriptRoot -Parent
    $script:updaterPath = Join-Path $script:repoRoot 'Chocolatey-Package-Updater.ps1'
    . $script:updaterPath
}

Describe 'Get-GitHubRelease' {
    Context 'When GitHub API call succeeds' {
        It 'returns LatestVersion and PublishedDateTime correctly' {
            Mock Invoke-RestMethod {
                return [PSCustomObject]@{
                    tag_name     = 'v1.5.0'
                    published_at = '2026-06-01T12:00:00Z'
                }
            }

            $release = Get-GitHubRelease -Owner 'testowner' -Repo 'testrepo'

            $release.LatestVersion | Should -Be 'v1.5.0'
            $release.PublishedDateTime | Should -Not -BeNullOrEmpty
            $expectedUtc = [DateTime]::Parse('2026-06-01T12:00:00Z', [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::RoundtripKind)
            $release.PublishedDateTime | Should -Be $expectedUtc.ToLocalTime()
        }
    }

    Context 'When GitHub API call fails' {
        It 'writes error message and exits with exit code 1' {
            $runnerScript = @"
. '$($script:updaterPath -replace "'", "''")'
function Invoke-RestMethod {
    throw 'GitHub API rate limit exceeded or network down'
}
Get-GitHubRelease -Owner 'testowner' -Repo 'testrepo'
"@
            $encodedBytes = [System.Text.Encoding]::Unicode.GetBytes($runnerScript)
            $encodedCmd = [System.Convert]::ToBase64String($encodedBytes)

            $proc = Start-Process -FilePath 'pwsh' `
                -ArgumentList '-NoProfile', '-EncodedCommand', $encodedCmd `
                -Wait -PassThru -NoNewWindow -RedirectStandardError "$env:TEMP/gh_test_err.txt" -RedirectStandardOutput "$env:TEMP/gh_test_out.txt"

            $proc.ExitCode | Should -Be 1

            $errOutput = Get-Content "$env:TEMP/gh_test_err.txt" -Raw -ErrorAction SilentlyContinue
            $stdOutput = Get-Content "$env:TEMP/gh_test_out.txt" -Raw -ErrorAction SilentlyContinue
            $allOutput = "$errOutput`n$stdOutput"

            $allOutput | Should -Match 'Unable to check for updates'
            $allOutput | Should -Match 'GitHub API rate limit exceeded or network down'

            Remove-Item "$env:TEMP/gh_test_err.txt", "$env:TEMP/gh_test_out.txt" -Force -ErrorAction SilentlyContinue
        }
    }
}

Describe 'UpdateFileContent' {
    BeforeEach {
        $script:testDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $script:testDir -Force | Out-Null
        $script:testFile = Join-Path $script:testDir 'testfile.txt'
    }

    AfterEach {
        if (Test-Path $script:testDir) {
            Remove-Item -Path $script:testDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It 'replaces matching pattern and returns true' {
        Set-Content -Path $script:testFile -Value "version = '1.0.0'`nauthor = 'tester'" -Encoding UTF8

        $result = UpdateFileContent -FilePath $script:testFile -Pattern "version = '1.0.0'" -Replacement "version = '1.0.1'"

        $result | Should -Be 'true'
        $updated = Get-Content -Path $script:testFile -Raw -Encoding UTF8
        $updated | Should -Match "version = '1.0.1'"
        $updated | Should -Not -Match "version = '1.0.0'"
    }

    It 'returns "No changes needed" when existing text already matches replacement' {
        Set-Content -Path $script:testFile -Value "version = '1.0.0'" -Encoding UTF8

        $result = UpdateFileContent -FilePath $script:testFile -Pattern "version = '1.0.0'" -Replacement "version = '1.0.0'"

        $result | Should -Be 'No changes needed'
        $content = Get-Content -Path $script:testFile -Raw -Encoding UTF8
        $content | Should -Match "version = '1.0.0'"
    }

    It 'returns "Pattern not found in file" when regex pattern does not match' {
        Set-Content -Path $script:testFile -Value "version = '1.0.0'" -Encoding UTF8

        $result = UpdateFileContent -FilePath $script:testFile -Pattern "nonexistent_pattern" -Replacement "anything"

        $result | Should -Be 'Pattern not found in file'
    }

    It 'returns "File not found" when file path does not exist' {
        $nonExistentFile = Join-Path $script:testDir 'missing_file.txt'

        $result = UpdateFileContent -FilePath $nonExistentFile -Pattern "version" -Replacement "new_version" -ErrorAction SilentlyContinue

        $result | Should -Be 'File not found'
    }

    It 'correctly escapes special regex characters in replacement validation' {
        Set-Content -Path $script:testFile -Value "url = 'http://example.com/old'" -Encoding UTF8

        $specialReplacement = "url = 'https://example.com/app?v=2.0&id=123[abc]'"
        $result = UpdateFileContent -FilePath $script:testFile -Pattern "url = 'http://example.com/old'" -Replacement $specialReplacement

        $result | Should -Be 'true'
        $updated = Get-Content -Path $script:testFile -Raw -Encoding UTF8
        $updated | Should -Be "$specialReplacement`r`n"
    }
}
