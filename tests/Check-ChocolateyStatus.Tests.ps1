BeforeAll {
    $script:repoRoot = Split-Path $PSScriptRoot -Parent
    $script:checkStatusScript = Join-Path $script:repoRoot 'scripts/Check-ChocolateyStatus.ps1'
    $script:logFile = Join-Path $script:repoRoot 'logs/pushed-versions.log'
}

Describe 'Check-ChocolateyStatus.ps1' {
    BeforeEach {
        if (Test-Path $script:logFile) {
            $script:backupLog = Get-Content $script:logFile -Raw
        } else {
            $script:backupLog = $null
        }
        $script:pkgId = "TestPkg-$([System.Guid]::NewGuid().ToString().Substring(0, 8))"
        $script:pkgVer = "1.2.3"
    }

    AfterEach {
        if ($null -ne $script:backupLog) {
            Set-Content -Path $script:logFile -Value $script:backupLog -NoNewline
        } else {
            Remove-Item -Path $script:logFile -Force -ErrorAction SilentlyContinue
        }
    }

    Context 'When package exists on Chocolatey.org (HTTP 200)' {
        It 'outputs SKIP_PUSH' {
            Mock Invoke-WebRequest {
                return [PSCustomObject]@{
                    StatusCode = 200
                }
            }

            $output = & $script:checkStatusScript -PackageId $script:pkgId -PackageVersion $script:pkgVer 6>&1

            $outputStr = $output | Out-String
            $outputStr | Should -Match 'SKIP_PUSH'
            $outputStr | Should -Match "Package version $script:pkgId/$script:pkgVer found on Chocolatey.org \(Status 200\)"
        }
    }

    Context 'When package is not found on Chocolatey.org (HTTP 404)' {
        It 'proceeds with push if not in local log' {
            Mock Invoke-WebRequest {
                $response = [System.Net.HttpWebResponse]::new()
                # Create a web exception with a 404 status
                $ex = [System.Net.WebException]::new('The remote server returned an error: (404) Not Found.')
                throw $ex
            }

            $output = & $script:checkStatusScript -PackageId $script:pkgId -PackageVersion $script:pkgVer 6>&1

            $outputStr = $output | Out-String
            $outputStr | Should -Match 'PROCEED_WITH_PUSH'
            $outputStr | Should -Match "Proceeding with push"
        }

        It 'skips push if already recorded in local log' {
            Mock Invoke-WebRequest {
                throw [System.Net.WebException]::new('404 Not Found')
            }

            # Add package to log file
            Add-Content -Path $script:logFile -Value "$script:pkgId/$script:pkgVer"

            $output = & $script:checkStatusScript -PackageId $script:pkgId -PackageVersion $script:pkgVer 6>&1

            $outputStr = $output | Out-String
            $outputStr | Should -Match 'SKIP_PUSH'
            $outputStr | Should -Match "found in local push log"
        }
    }

    Context 'When web request fails with general network error or timeout' {
        It 'proceeds with push as fallback when not in local log' {
            Mock Invoke-WebRequest {
                throw [System.Net.WebException]::new('Connection timed out')
            }

            $output = & $script:checkStatusScript -PackageId $script:pkgId -PackageVersion $script:pkgVer 6>&1

            $outputStr = $output | Out-String
            $outputStr | Should -Match 'PROCEED_WITH_PUSH'
        }
    }
}
