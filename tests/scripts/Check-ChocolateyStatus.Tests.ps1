# tests/scripts/Check-ChocolateyStatus.Tests.ps1
$scriptRoot = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
# Assuming the 'tests' directory is at the root, and 'scripts' is also at the root.
# So, from 'tests/scripts/', we go up two levels to the repo root, then into 'scripts/'.
$scriptUnderTestPath = Join-Path -Path $scriptRoot -ChildPath "..\..\scripts\Check-ChocolateyStatus.ps1"
$scriptUnderTest = Resolve-Path -Path $scriptUnderTestPath -ErrorAction SilentlyContinue

Describe "Check-ChocolateyStatus.ps1 - Basic Sanity" {
    Context "Script Discovery" {
        It "Should find the script under test" {
            $scriptUnderTest | Should -Not -BeNull
            Test-Path $scriptUnderTest.Path | Should -Be $true
        }
    }

    Context "Parameter Handling" {
        # Ensure the script is found before trying to dot-source it
        if ($scriptUnderTest) {
            It "Should load and accept mandatory parameters without throwing" {
                { . $scriptUnderTest.Path -PackageId "testpkg" -PackageVersion "1.0.0" } | Should -Not -Throw
            }
        } Else {
            It "Skipped: Script under test not found at $($scriptUnderTestPath)" {}
        }
    }
}
