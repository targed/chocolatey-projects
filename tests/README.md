# Test Suite Documentation

This directory contains the automated test suites for the repository tools and automation scripts.

## Prerequisites

- **PowerShell**: PowerShell 7+ (`pwsh`) recommended.
- **Pester**: Pester 5.0+ (tested with Pester 6.2.0).
  ```powershell
  Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser
  ```

## Running Tests

To run all tests in the repository:

```powershell
Invoke-Pester -Path ./tests -Output Detailed
```

To run a specific test suite:

```powershell
# Run updater tests
Invoke-Pester -Path ./tests/Chocolatey-Package-Updater.Tests.ps1 -Output Detailed

# Run package push automation tests
Invoke-Pester -Path ./tests/PushtoChocolatey.Tests.ps1 -Output Detailed

# Run Chocolatey status check tests
Invoke-Pester -Path ./tests/Check-ChocolateyStatus.Tests.ps1 -Output Detailed
# Run Claude uninstall tests
Invoke-Pester -Path ./tests/ClaudeUninstall.Tests.ps1 -Output Detailed

# Run Antigravity fetch scraper tests
Invoke-Pester -Path ./tests/FetchAG.Tests.ps1 -Output Detailed
```

## Structure

```
tests/
├── README.md                              # Test suite documentation & instructions
├── Chocolatey-Package-Updater.Tests.ps1   # Unit tests for Chocolatey-Package-Updater.ps1 (Get-GitHubRelease, CheckForUpdate, SendEmailMailjet, UpdateFileContent)
├── Check-ChocolateyStatus.Tests.ps1       # Integration / status check tests for scripts/Check-ChocolateyStatus.ps1
├── ClaudeUninstall.Tests.ps1              # Path sanitization and safe removal tests for Claude/tools/chocolateyuninstall.ps1
├── FetchAG.Tests.ps1                      # Content sanitization and extraction tests for Antigravity/fetchAG.ps1
└── PushtoChocolatey.Tests.ps1             # Unit tests for scripts/PushtoChocolatey.ps1
```

## Test Guidelines

1. **Isolation**: Never perform real network requests or live package pushes in unit tests. Mock `Invoke-RestMethod`, `Get-ChildItem`, and `choco`.
2. **Side-Effect Cleanup**: Clean up temporary files and directories created during test runs in `AfterEach` or `AfterAll` blocks.
3. **Environment State**: Save and restore environment variables (such as `$env:DRY_RUN` and `$env:CHOCO_API_KEY`) in `BeforeEach` / `AfterEach` blocks.
