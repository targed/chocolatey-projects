BeforeAll {
    $script:repoRoot = Split-Path $PSScriptRoot -Parent
    $script:updaterPath = Join-Path $script:repoRoot 'Chocolatey-Package-Updater.ps1'
    . $script:updaterPath

    function script:Invoke-CheckForUpdateSubprocess {
        param (
            [string]$LatestVersion,
            [string]$CurrentVersion,
            [string]$PowerShellGalleryName = ''
        )
        $runnerScript = @"
. '$($script:updaterPath -replace "'", "''")'
function Get-GitHubRelease {
    return [PSCustomObject]@{
        LatestVersion     = '$LatestVersion'
        PublishedDateTime = (Get-Date)
    }
}
CheckForUpdate -RepoOwner 'testowner' -RepoName 'testrepo' -CurrentVersion ([version]'$CurrentVersion') -PowerShellGalleryName '$PowerShellGalleryName'
"@
        $encodedBytes = [System.Text.Encoding]::Unicode.GetBytes($runnerScript)
        $encodedCmd = [System.Convert]::ToBase64String($encodedBytes)

        $proc = Start-Process -FilePath 'pwsh' `
            -ArgumentList '-NoProfile', '-EncodedCommand', $encodedCmd `
            -Wait -PassThru -NoNewWindow -RedirectStandardOutput "$env:TEMP/cfu_out.txt"

        $out = Get-Content "$env:TEMP/cfu_out.txt" -Raw -ErrorAction SilentlyContinue
        Remove-Item "$env:TEMP/cfu_out.txt" -Force -ErrorAction SilentlyContinue
        return [PSCustomObject]@{
            ExitCode = $proc.ExitCode
            Output   = $out
        }
    }
}

Describe 'Get-GitHubRelease' {
    Context 'When GitHub API call succeeds' {
        It 'queries the correct API endpoint and returns LatestVersion and PublishedDateTime' {
            $script:calledUri = $null
            Mock Invoke-RestMethod {
                param($Uri)
                $script:calledUri = $Uri
                return [PSCustomObject]@{
                    tag_name     = 'v1.5.0'
                    published_at = '2026-06-01T12:00:00Z'
                }
            }

            $release = Get-GitHubRelease -Owner 'testowner' -Repo 'testrepo'

            $script:calledUri | Should -Be 'https://api.github.com/repos/testowner/testrepo/releases/latest'
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

Describe 'CheckForUpdate' {
    Context 'When current version is equal to latest version' {
        It 'reports that the repository is up to date' {
            $result = Invoke-CheckForUpdateSubprocess -LatestVersion '1.2.0' -CurrentVersion '1.2.0'

            $result.ExitCode | Should -Be 0
            $result.Output | Should -Match 'testrepo is up to date'
            $result.Output | Should -Match 'Current version: 1.2.0'
            $result.Output | Should -Match 'Latest version: 1.2.0'
        }
    }

    Context 'When current version is newer than latest version' {
        It 'reports that the repository is up to date' {
            $result = Invoke-CheckForUpdateSubprocess -LatestVersion '1.0.0' -CurrentVersion '2.0.0'

            $result.ExitCode | Should -Be 0
            $result.Output | Should -Match 'testrepo is up to date'
            $result.Output | Should -Match 'Current version: 2.0.0'
            $result.Output | Should -Match 'Latest version: 1.0.0'
        }
    }

    Context 'When current version is older than latest version' {
        It 'reports that a new version is available with update instructions' {
            $result = Invoke-CheckForUpdateSubprocess -LatestVersion '2.0.0' -CurrentVersion '1.0.0' -PowerShellGalleryName 'Chocolatey-Package-Updater'

            $result.ExitCode | Should -Be 0
            $result.Output | Should -Match 'A new version of testrepo is available'
            $result.Output | Should -Match 'Current version: 1.0.0'
            $result.Output | Should -Match 'Latest version: 2.0.0'
            $result.Output | Should -Match 'Install-Script Chocolatey-Package-Updater -Force'
        }
    }
}

Describe 'SendEmailMailjet' {
    BeforeEach {
        $env:MAILJET_API_KEY = 'mock_mailjet_key'
        $env:MAILJET_API_SECRET = 'mock_mailjet_secret'
        $env:MAILJET_FROM_EMAIL = 'sender@example.com'
        $env:MAILJET_FROM_NAME = 'Package Maintainer'
        $env:MAILJET_TO_EMAIL = 'receiver@example.com'
        $env:MAILJET_TO_NAME = 'Admin'
    }

    AfterEach {
        Remove-Item env:MAILJET_API_KEY, env:MAILJET_API_SECRET, env:MAILJET_FROM_EMAIL, env:MAILJET_FROM_NAME, env:MAILJET_TO_EMAIL, env:MAILJET_TO_NAME -ErrorAction SilentlyContinue
    }

    Context 'When required environment variables are missing' {
        It 'writes a warning and exits early without calling API' {
            Remove-Item env:MAILJET_API_KEY -ErrorAction SilentlyContinue
            Mock Invoke-RestMethod {
                throw 'Invoke-RestMethod should not be called when credentials are missing'
            }

            $output = SendEmailMailjet -Subject 'Test' -TextContent 'Body' 3>&1

            $outputStr = $output | Out-String
            $outputStr | Should -Match 'One or more required environment variables are missing'
        }
    }

    Context 'When Mailjet API request fails (catch block error handling)' {
        It 'catches the exception and writes warning details' {
            Mock Invoke-RestMethod {
                throw 'Mailjet API 503 Service Unavailable'
            }

            $output = SendEmailMailjet -Subject 'Update Alert' -TextContent 'Package update details' 3>&1

            $outputStr = $output | Out-String
            $outputStr | Should -Match 'Failed to send email'
            $outputStr | Should -Match 'Mailjet API 503 Service Unavailable'
        }
    }

    Context 'When Mailjet API request succeeds' {
        It 'outputs email sent successfully' {
            Mock Invoke-RestMethod {
                return [PSCustomObject]@{
                    Messages = @(
                        [PSCustomObject]@{
                            Status = 'success'
                        }
                    )
                }
            }

            $output = SendEmailMailjet -Subject 'Update Alert' -TextContent 'Package update details'

            $output | Should -Be 'Email sent successfully.'
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
