BeforeAll {
    $script:pushScriptPath = Join-Path $PSScriptRoot 'PushtoChocolatey.ps1'
    if (-not (Get-Command -Name choco -CommandType Function -ErrorAction SilentlyContinue)) {
        function global:choco { }
    }
}

Describe 'PushtoChocolatey.ps1' {
    BeforeEach {
        $script:savedDryRun = $env:DRY_RUN
        $script:savedApiKey = $env:CHOCO_API_KEY
        $script:chocoCalls = @()
    }

    AfterEach {
        $env:DRY_RUN = $script:savedDryRun
        $env:CHOCO_API_KEY = $script:savedApiKey
    }

    Context 'When no recent .nupkg packages are found' {
        It 'outputs that no updated Claude package was found to push' {
            Mock Get-ChildItem {
                return @()
            }

            $output = . $script:pushScriptPath 6>&1

            $outputStr = $output | Out-String
            $outputStr | Should -Match 'No updated Claude package found to push'
            $outputStr | Should -Not -Match 'Found updated Claude package to push'
        }

        It 'ignores packages older than 1 hour' {
            Mock Get-ChildItem {
                return @(
                    [PSCustomObject]@{
                        FullName      = 'C:\packages\Claude\Claude.0.9.0.nupkg'
                        LastWriteTime = (Get-Date).AddHours(-2)
                    }
                )
            }

            $output = . $script:pushScriptPath 6>&1

            $outputStr = $output | Out-String
            $outputStr | Should -Match 'No updated Claude package found to push'
        }
    }

    Context 'When updated .nupkg packages are found and DRY_RUN is enabled' {
        It 'outputs dry run message and does not execute choco push' {
            $env:DRY_RUN = 'true'
            $fakeNupkg = 'C:\packages\Claude\Claude.1.0.0.nupkg'

            Mock Get-ChildItem {
                return @(
                    [PSCustomObject]@{
                        FullName      = $fakeNupkg
                        LastWriteTime = (Get-Date).AddMinutes(-5)
                    }
                )
            }

            Mock choco {
                param([Parameter(ValueFromRemainingArguments)]$Args)
                $script:chocoCalls += ,$Args
                throw 'choco should not be called in DRY_RUN mode!'
            }

            $output = . $script:pushScriptPath 6>&1

            $outputStr = $output | Out-String
            $outputStr | Should -Match 'Found updated Claude package to push'
            $outputStr | Should -Match ([regex]::Escape("Pushing package: $fakeNupkg"))
            $outputStr | Should -Match ([regex]::Escape("DRY RUN: Would have pushed $fakeNupkg to Chocolatey"))
            $script:chocoCalls.Count | Should -Be 0
        }
    }

    Context 'When updated .nupkg packages are found and DRY_RUN is disabled' {
        It 'calls choco push with the package path and source' {
            $env:DRY_RUN = 'false'
            $env:CHOCO_API_KEY = 'mock-api-key-12345'
            $fakeNupkg = 'C:\packages\Claude\Claude.1.0.0.nupkg'

            Mock Get-ChildItem {
                return @(
                    [PSCustomObject]@{
                        FullName      = $fakeNupkg
                        LastWriteTime = (Get-Date).AddMinutes(-10)
                    }
                )
            }

            Mock choco {
                param([Parameter(ValueFromRemainingArguments)]$Args)
                $script:chocoCalls += ,$Args
            }

            $output = . $script:pushScriptPath 6>&1

            $outputStr = $output | Out-String
            $outputStr | Should -Match 'Found updated Claude package to push'
            $outputStr | Should -Match ([regex]::Escape("Pushing package: $fakeNupkg"))
            $outputStr | Should -Not -Match 'DRY RUN'

            $script:chocoCalls.Count | Should -Be 1
            $argsJoined = $script:chocoCalls[0] -join ' '
            $argsJoined | Should -Match ([regex]::Escape($fakeNupkg))
            $argsJoined | Should -Match '--source=https://push.chocolatey.org/'
            $argsJoined | Should -Match '--api-key=mock-api-key-12345'
        }
    }
}
