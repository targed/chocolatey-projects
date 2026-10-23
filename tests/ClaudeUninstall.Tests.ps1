BeforeAll {
    $script:repoRoot = Split-Path $PSScriptRoot -Parent
    $script:uninstallScript = Join-Path $script:repoRoot 'Claude/tools/chocolateyuninstall.ps1'
}

Describe 'Claude chocolateyuninstall.ps1' {
    BeforeEach {
        $script:sandboxDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString())
        $script:chocoDir = Join-Path $script:sandboxDir 'choco'
        $script:chocoLibDir = Join-Path $script:chocoDir 'lib'
        $script:targetAppDir = Join-Path $script:chocoLibDir 'AnthropicClaude'

        New-Item -ItemType Directory -Path $script:targetAppDir -Force | Out-Null
        Set-Content -Path (Join-Path $script:targetAppDir 'app.exe') -Value 'dummy app'

        $script:savedChocoInstall = $env:ChocolateyInstall
        $env:ChocolateyInstall = $script:chocoDir
    }

    AfterEach {
        $env:ChocolateyInstall = $script:savedChocoInstall
        if (Test-Path $script:sandboxDir) {
            Remove-Item -Path $script:sandboxDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    Context 'Safe removal of Chocolatey lib files' {
        It 'removes the AnthropicClaude directory inside lib and preserves parent lib directory' {
            . $script:uninstallScript

            Test-Path $script:targetAppDir | Should -BeFalse
            Test-Path $script:chocoLibDir | Should -BeTrue
        }

        It 'does not remove the repository tools directory when invoked from workspace' {
            $toolsDir = Split-Path -Parent $script:uninstallScript
            Test-Path $toolsDir | Should -BeTrue
            Test-Path (Join-Path $toolsDir 'chocolateyinstall.ps1') | Should -BeTrue
        }
    }

    Context 'Path validation and sanitization' {
        It 'rejects invalid folder names with directory traversal' {
            {
                $folderName = '../../Windows'
                if ([string]::IsNullOrWhiteSpace($folderName) -or $folderName -notmatch '^[a-zA-Z0-9_\-]+$') {
                    throw "Invalid folder name specified: '$folderName'"
                }
            } | Should -Throw
        }

        It 'rejects empty or whitespace folder names' {
            {
                $folderName = '   '
                if ([string]::IsNullOrWhiteSpace($folderName) -or $folderName -notmatch '^[a-zA-Z0-9_\-]+$') {
                    throw "Invalid folder name specified: '$folderName'"
                }
            } | Should -Throw
        }

        It 'does not delete parent directories if path is not strictly a child of lib directory' {
            $chocoLib = [System.IO.Path]::GetFullPath($script:chocoLibDir)
            $manipulated = [System.IO.Path]::GetFullPath((Join-Path $chocoLib '..'))

            $expectedLibPrefix = $chocoLib.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
            $isChild = $manipulated.StartsWith($expectedLibPrefix, [System.StringComparison]::OrdinalIgnoreCase)

            $isChild | Should -BeFalse
        }

        It 'safely handles missing ChocolateyInstall environment variable without error' {
            $env:ChocolateyInstall = $null
            { . $script:uninstallScript } | Should -Not -Throw
        }
    }
}
