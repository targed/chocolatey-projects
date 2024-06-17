<#PSScriptInfo

.VERSION 0.0.11

.GUID 9b612c16-25c0-4a40-afc7-f876274e7e8c

.AUTHOR asheroto

.COMPANYNAME asheroto

.TAGS PowerShell Windows Chocolatey choco package updater update maintain maintainer monitor monitoring alert notification exe installer automatic auto automated automation schedule scheduled scheduler task

.PROJECTURI https://github.com/asheroto/Chocolatey-Package-Updater

.RELEASENOTES
[Version 0.0.1] - Initial release, deployment and additional features still under development.
[Version 0.0.2] - Fixed wrong checksum variable being used
[Version 0.0.3] - Added support for stripping out the version number from the Product Version, as well as checking the File Version if the Product Version is not available. Improved pattern matching. Remove extra debug statements. Added logic to check if VERIFICATION.txt checksum changed. Add -Version and -CheckForUpdate parameters and logic. Added supported for ScrapeUrl, ScrapePattern, and VERSION replacement in URL.
[Version 0.0.4] - Major improvements. Added support for FileUrl64, checksum64.
[Version 0.0.5] - Abstracted version/checksum comparison into its own function.
[Version 0.0.6] - Added support for GitHubRepoUrl so that the latest version can be scraped from GitHub's API. Added GitHub repo example.
[Version 0.0.7] - Added additional wait time for cleanup to ensure files are release from use before deletion.
[Version 0.0.8] - Improved help. Added Help parameter. Added loop to repeatedly attempt file deletion if it's in use, mitigating file deletion prevention by antivirus software scanning download.
[Version 0.0.9] - Improved ProductVersion/FileVersion detection, only returns applicable Chocolatey version number despite the version provided in the metadata of the file/installer.
[Version 0.0.10] - Added disable IPv6 to aria2c args.
[Version 0.0.11] - Added ignore version.

#>

<#

.SYNOPSIS
Streamline the management of Chocolatey packages by automating version updates, checksum validations, and alert notifications.

.DESCRIPTION
See project site for instructions on how to use including full parameter list and examples.

The script simplifies the process of updating Chocolatey packages by providing automated functionality to:
- No functions or regex expressions to write: everything happens automatically!
- Updates the version in the nuspec file.
- Updates the url/checksum and url64/checksum64 (if specified) in the ChocolateyInstall.ps1 script.
- Updates the checksum and checksum64 (if specified) in the VERIFICATION.txt file (if it exists).
- Updates the version number in the download URL (if specified).
- Sends an alert to a designated URL.
- Supports EXE files distributed in the package.
- Supports variable and hash table formats for checksum in the ChocolateyInstall.ps1 script.
- Supports single and double quotes for checksum in the ChocolateyInstall.ps1 script.
- Automatic support for aria2 download manager as well as Invoke-WebRequest.
- Supports scraping the version number from the download URL.
- Supports version number replacement in the download URL.
- Supports getting the latest version from a GitHub repository.

.EXAMPLE
# Required at top of each script
# Set vars to the script and the parent path ($ScriptPath MUST be defined for the UpdateChocolateyPackage function to work)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

.EXAMPLE
# Create a hash table to store package information
$packageInfo = @{
    PackageName         = "fxsound"
    FileUrl             = 'https://download.fxsound.com/fxsoundlatest'   # URL to download the file from
    FileDestinationPath = '.\tools\fxsound_setup.exe'                    # Path to move/rename the temporary file to (if EXE is distributed in package
    Alert               = $true                                          # If the package is updated, send a message to the maintainer for review
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo

.EXAMPLE
To update a Chocolatey package, run the following command:
UpdateChocolateyPackage -PackageName "fxsound" -FileUrl "https://download.fxsound.com/fxsoundlatest" -Alert $true

.EXAMPLE
To update a Chocolatey package with additional parameters, run the following command:
UpdateChocolateyPackage -PackageName "fxsound" -FileUrl "https://download.fxsound.com/fxsoundlatest" -FileDownloadTempPath ".\fxsound_setup_temp.exe" -FileDestinationPath ".\tools\fxsound_setup.exe" -NuspecPath ".\fxsound.nuspec" -InstallScriptPath ".\tools\ChocolateyInstall.ps1" -VerificationPath ".\tools\VERIFICATION.txt" -Alert $true

.NOTES
- Version: 0.0.11
- Created by: asheroto
- See project site for instructions on how to use including full parameter list and examples.

.LINK
Project Site: https://github.com/asheroto/Chocolatey-Package-Updater

#>
[CmdletBinding()]
param (
    [switch]$CheckForUpdate,
    [switch]$Version,
    [switch]$Help
)

# ============================================================================ #
# Initial vars
# ============================================================================ #

$CurrentVersion = '0.0.11'
$RepoOwner = 'asheroto'
$RepoName = 'Chocolatey-Package-Updater'
$SoftwareName = 'Chocolatey Package Updater'
$PowerShellGalleryName = 'Chocolatey-Package-Updater'

# Suppress progress bar (makes downloading super fast)
$ProgressPreference = 'SilentlyContinue'

# Display version if -Version is specified
if ($Version.IsPresent) {
    $CurrentVersion
    exit 0
}

# Display full help if -Help is specified
if ($Help) {
    Get-Help -Name $MyInvocation.MyCommand.Source -Full
    exit 0
}

function Get-GitHubRelease {
    <#
        .SYNOPSIS
        Fetches the latest release information of a GitHub repository.

        .DESCRIPTION
        This function uses the GitHub API to get information about the latest release of a specified repository, including its version and the date it was published.

        .PARAMETER Owner
        The GitHub username of the repository owner.

        .PARAMETER Repo
        The name of the repository.

        .EXAMPLE
        Get-GitHubRelease -Owner "asheroto" -Repo "winget-install"
        This command retrieves the latest release version and published datetime of the winget-install repository owned by asheroto.
    #>
    [CmdletBinding()]
    param (
        [string]$Owner,
        [string]$Repo
    )
    try {
        $url = "https://api.github.com/repos/$Owner/$Repo/releases/latest"
        $response = Invoke-RestMethod -Uri $url -ErrorAction Stop

        $latestVersion = $response.tag_name
        $publishedAt = $response.published_at

        # Convert UTC time string to local time
        $UtcDateTime = [DateTime]::Parse($publishedAt, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::RoundtripKind)
        $PublishedLocalDateTime = $UtcDateTime.ToLocalTime()

        [PSCustomObject]@{
            LatestVersion     = $latestVersion
            PublishedDateTime = $PublishedLocalDateTime
        }
    } catch {
        Write-Error "Unable to check for updates.`nError: $_"
        exit 1
    }
}

function CheckForUpdate {
    param (
        [string]$RepoOwner,
        [string]$RepoName,
        [version]$CurrentVersion,
        [string]$PowerShellGalleryName
    )

    $Data = Get-GitHubRelease -Owner $RepoOwner -Repo $RepoName

    if ($Data.LatestVersion -gt $CurrentVersion) {
        Write-Output "`nA new version of $RepoName is available.`n"
        Write-Output "Current version: $CurrentVersion."
        Write-Output "Latest version: $($Data.LatestVersion)."
        Write-Output "Published at: $($Data.PublishedDateTime).`n"
        Write-Output "You can download the latest version from https://github.com/$RepoOwner/$RepoName/releases`n"
        if ($PowerShellGalleryName) {
            Write-Output "Or you can run the following command to update:"
            Write-Output "Install-Script $PowerShellGalleryName -Force`n"
        }
    } else {
        Write-Output "`n$RepoName is up to date.`n"
        Write-Output "Current version: $CurrentVersion."
        Write-Output "Latest version: $($Data.LatestVersion)."
        Write-Output "Published at: $($Data.PublishedDateTime)."
        Write-Output "`nRepository: https://github.com/$RepoOwner/$RepoName/releases`n"
    }
    exit 0
}

# ============================================================================ #
# Initial checks
# ============================================================================ #

# Check for updates if -CheckForUpdate is specified
if ($CheckForUpdate) {
    CheckForUpdate -RepoOwner $RepoOwner -RepoName $RepoName -CurrentVersion $CurrentVersion -PowerShellGalleryName $PowerShellGalleryName
}

# Heading
Write-Output "$SoftwareName $CurrentVersion"
Write-Output "To check for updates, run $RepoName -CheckForUpdate"

function UpdateFileContent {
    [OutputType([System.String])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        [Parameter(Mandatory = $true)]
        [string]$Pattern,
        [Parameter(Mandatory = $true)]
        [string]$Replacement
    )
    $absolutePath = (Resolve-Path $FilePath).ProviderPath
    Write-Debug "Working with file: $absolutePath"

    if (Test-Path $absolutePath) {
        $fileContent = Get-Content $absolutePath -Raw

        if ($fileContent -match $Pattern) {
            Write-Debug "Pattern found in file"
            $matchedText = $matches[0]  # Capture the matched text

            if ($matchedText -eq $Replacement) {
                Write-Debug "Replacement text is the same as the existing text. No changes needed."
                return "No changes needed"
            } else {
                $updatedContent = $fileContent -replace $Pattern, $Replacement
                [System.IO.File]::WriteAllText($absolutePath, $updatedContent)
                $verifyContent = Get-Content $absolutePath -Raw

                # Escape special characters in the replacement string for regex matching
                $escapedReplacement = [regex]::Escape($Replacement)
                if ($verifyContent -match $escapedReplacement) {
                    Write-Debug "Replacement verified in file"
                    return "true"
                } else {
                    return "Replacement not found in file"
                }
            }
        } else {
            return "Pattern not found in file"
        }
    } else {
        return "File not found"
    }
}

function HandleUpdateResult {
    param (
        [string]$Result,
        [string]$SuccessMessage,
        [string]$FailureMessage
    )

    if ($Result -eq "true") {
        Write-Output $SuccessMessage
    } elseif ($Result -eq "No changes needed") {
        Write-Output "No changes were needed."
    } else {
        Write-Output $FailureMessage
    }
}

function SendAlertRaw {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Subject,

        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    # Note - you might consider using ntfy.sh, it's an awesome tool
    # In this script, however, I'm using a custom service that I built
    # This function gets the URL from a secure string file (encrypted) and sends the alert by making a POST request to the URL
    # If you just want to make a GET/POST request, comment out the lines below until you get to the if($alertUrl)/Invoke-WebRequest section and replace with your own code

    # To save the URL as a secure string, run the following command in the comment block:
    <#
        # Connect
        $CredsFile = "C:\Path\To\SecureString\Folder\SecretURL.txt"

        # Store credential in a file as secure string
        Read-Host "Secret URL" -AsSecureString | ConvertFrom-SecureString | Out-File $CredsFile
    #>

    # Environment variable contains path to $CredsFile (create or change below as needed)
    # Get the secret URL from the secure string file using the path in the environment variable
    $CredsFile = [System.Environment]::GetEnvironmentVariable('EMAIL_NOTIFICATION_CREDS_PATH', [System.EnvironmentVariableTarget]::User)

    # Convert the secure string to a string
    $secret = Get-Content $CredsFile | ConvertTo-SecureString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret)
    $alertUrl = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

    # Replace {SUBJECT} and {MESSAGE} in the URL
    $alertUrl = $alertUrl -replace '{SUBJECT}', $Subject
    $alertUrl = $alertUrl -replace '{MESSAGE}', $Message

    if ($alertUrl) {
        try {
            Invoke-WebRequest -Uri $alertUrl -Method Post -Body $Message -ContentType "text/plain" | Out-Null
            Write-Output "Alert sent."
        } catch {
            Write-Warning "Failed to send alert."
        }
    }
}

function SendAlert {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Subject,

        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [boolean]$Alert = $true
    )

    # If Alert is false, let the user know that the alert is disabled
    if (!$Alert) {
        Write-Output "Alert disabled. Skipping alert."
        return
    }

    # Output sending alert
    Write-Output "Sending alert..."

    # Create the HTML body for the notification
    $date = Get-Date -Format "yyyy-MM-dd hh:mm:ss tt"
    $body = "<html><body>"
    $body += "<font face='Arial'>"
    $body += "<p>$Message</p>"
    $body += "<p><strong>Time:</strong> $date</p>"
    $body += "</font>"
    $body += "</body></html>"

    Write-Verbose "Sending alert with subject: $Subject"
    Write-Verbose "Sending alert with body:`n$body"

    # Send the alert
    SendAlertRaw -Subject $Subject -Message $body
}

function Write-Section {
    <#
        .SYNOPSIS
        Prints a text block surrounded by a section divider for enhanced output readability.

        .DESCRIPTION
        This function takes a message input and prints it to the console, surrounded by a section divider made of hash characters.
        It enhances the readability of console output by categorizing messages based on the Type parameter.

        .PARAMETER Message
        The message to be printed within the section divider. This parameter is mandatory.

        .PARAMETER Type
        The type of message to display. Possible values: "Output" (default), "Debug," "Warning," "Information," "Verbose."

        .EXAMPLE
        Write-Section -Message "This is a sample message."

        This command prints the provided message surrounded by a section divider. Because the Type parameter is not specified, it defaults to "Output."

        .EXAMPLE
        Write-Section "This is another sample message."

        This command also prints the message surrounded by a section divider. The -Message parameter is implied and does not need to be explicitly named.

        .EXAMPLE
        Write-Section -Message "This is a warning message." -Type "Warning"

        This command prints the provided message surrounded by a section divider and uses Write-Warning to display the message, due to the Type parameter being set to "Warning."
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [ValidateSet("Output", "Debug", "Warning", "Information", "Verbose")]
        [string]$Type = "Output"
    )

    $consoleWidth = [System.Console]::WindowWidth - 2
    $prependLength = 0

    switch ($Type) {
        "Output" { $writeCmd = { Write-Output $args[0] } }
        "Debug" { $writeCmd = { Write-Debug $args[0] }; $prependLength = 7 }
        "Warning" { $writeCmd = { Write-Warning $args[0] }; $prependLength = 9 }
        "Information" { $writeCmd = { Write-Information $args[0] }; }
        "Verbose" { $writeCmd = { Write-Verbose $args[0] }; $prependLength = 9 }
    }

    $divider = "#" * ($consoleWidth - $prependLength)
    & $writeCmd $divider

    $words = $Message -split ' '
    $line = "# "
    foreach ($word in $words) {
        if (($line.Length + $word.Length + 1) -gt ($consoleWidth - $prependLength - 1)) {
            $line = $line.PadRight($consoleWidth - $prependLength - 1) + "#"
            & $writeCmd $line
            $line = "# "
        }
        $line += "$word "
    }

    if ($line.Trim().Length -gt 1) {
        $line = $line.PadRight($consoleWidth - $prependLength - 1) + "#"
        & $writeCmd $line
    }

    $divider = "#" * ($consoleWidth - $prependLength)
    & $writeCmd $divider
}

function Get-LatestGitHubReleaseVersion {
    param (
        [Parameter(Mandatory = $true)]
        [string]$GitHubRepoUrl
    )

    # Extract the username and repo name from the provided URL
    $repoDetails = $GitHubRepoUrl -replace '^https://github.com/', '' -split '/'

    $username = $repoDetails[0]
    $repoName = $repoDetails[1]

    $apiUrl = "https://api.github.com/repos/$username/$repoName/releases/latest"

    $response = Invoke-RestMethod -Uri $apiUrl
    $latestVersionTag = $response.tag_name

    # Use regex to extract version number
    if ($latestVersionTag -match '(\d+\.\d+\.\d+)') {
        return $matches[1]
    } else {
        throw "Failed to extract version from tag: $latestVersionTag"
    }
}

function UpdateChocolateyPackage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$PackageName,

        [Parameter(Mandatory = $true)]
        [string]$FileUrl,

        [Parameter(Mandatory = $false)]
        [string]$FileUrl64,

        [Parameter(Mandatory = $false)]
        [string]$FileDownloadTempPath,

        [Parameter(Mandatory = $false)]
        [string]$FileDownloadTempPath64,

        [Parameter(Mandatory = $false)]
        [string]$FileDestinationPath,

        [Parameter(Mandatory = $false)]
        [string]$FileDestinationPath64,

        [Parameter(Mandatory = $false)]
        [string]$NuspecPath = ".\$PackageName.nuspec",

        [Parameter(Mandatory = $false)]
        [string]$InstallScriptPath = '.\tools\ChocolateyInstall.ps1',

        [Parameter(Mandatory = $false)]
        [string]$VerificationPath = '.\tools\VERIFICATION.txt',

        [Parameter(Mandatory = $false)]
        [boolean]$Alert = $true,

        [Parameter(Mandatory = $false)]
        [string]$ScrapeUrl,

        [Parameter(Mandatory = $false)]
        [string]$ScrapePattern,

        [Parameter(Mandatory = $false)]
        [string]$DownloadUrlScrapePattern,

        [Parameter(Mandatory = $false)]
        [string]$DownloadUrlScrapePattern64,

        [Parameter(Mandatory = $false)]
        [string]$GitHubRepoUrl,

        [Parameter(Mandatory = $false)]
        [string]$IgnoreVersion
    )

    function Try-DeleteFile {
        # Try to delete the file and return true if successful, false if not
        param (
            [string]$filePath
        )
        try {
            Remove-Item -Path $filePath -Force -ErrorAction Stop
            return $true
        } catch {
            return $false
        }
    }

    function WaitForReleaseAndDelete {
        # Wait for the file to be released by the process and delete it
        param (
            [string]$filePath,
            [int]$maxTimeout
        )
        $fileName = [System.IO.Path]::GetFileName($filePath)
        $elapsedTime = 0
        while ($elapsedTime -lt $maxTimeout) {
            if (Try-DeleteFile -filePath $filePath) {
                Write-Output "$fileName deleted"
                return
            }
            Start-Sleep -Seconds 1
            $elapsedTime++
        }
        Write-Output "Timeout reached, $fileName not deleted"
    }

    function CleanupFileDownload {
        # Check if FileDownloadTempDelete is not set
        # Check if the file exists at the specified path
        if (Test-Path $FileDownloadTempPath) {
            # Remove the file
            Write-Debug "Removing temporary file: $FileDownloadTempPath"
            WaitForReleaseAndDelete -filePath $FileDownloadTempPath -maxTimeout 10
        }

        # If FileUrl64 is used, check if the file exists at the specified path
        if ($FileUrl64 -and (Test-Path $FileDownloadTempPath64)) {
            Write-Debug "Removing temporary file: $FileDownloadTempPath64"
            WaitForReleaseAndDelete -filePath $FileDownloadTempPath64 -maxTimeout 10
        }
    }

    # Internal function to handle file download
    function DownloadFile {
        param(
            [string]$Url,
            [string]$TempPath,
            [boolean]$Is64Bit = $false
        )

        if ($Is64Bit -eq $false) {
            Write-Output "Downloading file: $url"
        } else {
            Write-Output "Downloading file (64-bit): $url"
        }

        Write-Debug "Saving to: $tempPath"

        # Check if aria2c exists and use it for downloading if possible
        if (Get-Command aria2c -ErrorAction SilentlyContinue) {
            Write-Debug "aria2c is detected and will be used to download the file."

            # Extract the directory part and the file part from the absolute path (aria2c treats paths as relative)
            $directoryPart = [System.IO.Path]::GetDirectoryName($tempPath)
            $filePart = [System.IO.Path]::GetFileName($tempPath)

            # Construct the aria2c command line arguments
            # Using spoofed user agent because some sites block aria2c
            $aria2cArgs = @("-d", $directoryPart, "-o", $filePart, $url, "--disable-ipv6")

            if ($DebugPreference -eq 'SilentlyContinue') {
                $aria2cArgs += '--quiet'
            }

            # Run aria2c
            & 'aria2c' $aria2cArgs
        } else {
            Write-Debug "Using Invoke-WebRequest to download the file."
            Invoke-WebRequest -Uri $url -OutFile $tempPath
        }

        # Verify the file exists
        if (Test-Path $tempPath) {
            Write-Debug "File exists: $tempPath"
        } else {
            throw "File not found: $tempPath"
        }
    }

    function Get-ProductVersion {
        param(
            [string]$FileDownloadTempPath,
            [string]$ForceVersionNumber
        )

        $ProductVersion = $null
        $versionPattern = '(\d+\.\d+)(\.\d+)?(\.\d+)?'

        if ($ForceVersionNumber) {
            $ProductVersion = $ForceVersionNumber
        } else {
            $fileInfo = (Get-Command $FileDownloadTempPath).FileVersionInfo

            if ($fileInfo.ProductVersion) {
                $matches = [regex]::Match($fileInfo.ProductVersion, $versionPattern)
                if ($matches.Success) {
                    $majorMinor = $matches.Groups[1].Value
                    $patch = $matches.Groups[2].Success ? $matches.Groups[2].Value : ".0"
                    $ProductVersion = $majorMinor + $patch
                }
            }

            if ($null -eq $ProductVersion -and $fileInfo.FileVersion) {
                $matches = [regex]::Match($fileInfo.FileVersion, $versionPattern)
                if ($matches.Success) {
                    $majorMinor = $matches.Groups[1].Value
                    $patch = $matches.Groups[2].Success ? $matches.Groups[2].Value : ".0"
                    $ProductVersion = $majorMinor + $patch
                }
            }
        }

        return $ProductVersion
    }

    function PerformComparison {
        param (
            [string]$ProductVersion,
            [string]$NuspecVersion,
            [string]$ChocolateyInstallChecksum,
            [string]$NewChecksum,
            [string]$ChocolateyInstallChecksum64,
            [string]$NewChecksum64,
            [string]$VerificationPath,
            [string]$VerificationChecksum,
            [string]$VerificationChecksum64,
            [string]$FileUrl64,
            [string]$IgnoreVersion
        )

        $result = @{}
        $result["ProductVersion"] = $ProductVersion -eq $NuspecVersion
        $result["ChocolateyInstallChecksum"] = $ChocolateyInstallChecksum -eq $NewChecksum

        if ($FileUrl64) {
            $result["ChocolateyInstallChecksum64"] = $ChocolateyInstallChecksum64 -eq $NewChecksum64
        }

        if (Test-Path $VerificationPath) {
            $result["VerificationChecksum"] = $VerificationChecksum -eq $NewChecksum

            if ($FileUrl64) {
                $result["VerificationChecksum64"] = $VerificationChecksum64 -eq $NewChecksum64
            }
        }

        $result["OverallComparison"] = $result.Values -contains $false

        Write-Debug "Comparison results: $($result | Out-String)"
        return $result
    }

    # ============================================================================ #
    #  Main Script
    # ============================================================================ #

    try {
        # Heading
        Write-Section "Updating package: $PackageName"

        # Initialization and Path Management
        Push-Location
        Set-Location $ScriptPath
        Write-Debug "Current directory: $pwd"

        # Temporary File Cleanup
        CleanupFileDownload

        # FileDownloadTempPath Management
        if (-not $FileDownloadTempPath) {
            $FileDownloadTempPath = Join-Path -Path $env:TEMP -ChildPath "${PackageName}_setup_temp.exe"
        }

        if ($FileUrl64 -and -not $FileDownloadTempPath64) {
            $FileDownloadTempPath64 = Join-Path -Path $env:TEMP -ChildPath "${PackageName}_setup_temp_64.exe"
        }

        # Scrape Version if Applicable
        $ForceVersionNumber = ''
        if ($ScrapeUrl -and $ScrapePattern) {
            Write-Debug "Scraping URL: $ScrapeUrl"
            Write-Debug "Scrape pattern: $ScrapePattern"

            $page = Invoke-WebRequest -Uri $ScrapeUrl
            if ($page.Content -match $ScrapePattern -and $matches[0] -match '^\d+(\.\d+){1,3}$') {
                Write-Output "Scraped version: $($matches[0])"
                $ForceVersionNumber = $matches[0]
            } else {
                throw "No match found or invalid version."
            }
        }

        # Scrape download URL if applicable
        if ($ScrapeUrl -and $DownloadUrlScrapePattern) {
            Write-Debug "Scraping URL: $ScrapeUrl"
            Write-Debug "Download URL scrape pattern: $DownloadUrlScrapePattern"

            $page = Invoke-WebRequest -Uri $ScrapeUrl
            if ($page.Content -match $DownloadUrlScrapePattern) {
                Write-Output "Scraped download URL: $($matches[0])"
                $FileUrl = $matches[0]
            } else {
                throw "No match found or invalid version."
            }

            # Scrape 64-bit download URL if applicable
            if ($DownloadUrlScrapePattern64) {
                Write-Debug "Scraping URL: $ScrapeUrl"
                Write-Debug "Download URL scrape pattern (64-bit): $DownloadUrlScrapePattern"

                $page = Invoke-WebRequest -Uri $ScrapeUrl
                if ($page.Content -match $DownloadUrlScrapePattern64) {
                    Write-Output "Scraped 64-bit download URL: $($matches[0])"
                    $FileUrl64 = $matches[0]
                } else {
                    throw "No match found or invalid version."
                }
            }
        }

        # If GitHubRepoUrl is specified, get the latest version from GitHub
        if ($GitHubRepoUrl) {
            Write-Debug "GitHub repo URL: $GitHubRepoUrl"
            $ForceVersionNumber = Get-LatestGitHubReleaseVersion -GitHubRepoUrl $GitHubRepoUrl
        }

        # URL Modification with Version Number
        if ($ForceVersionNumber -and $FileUrl) {
            $FileUrl = $FileUrl -replace '{VERSION}', $ForceVersionNumber
        }
        if ($ForceVersionNumber -and $FileUrl64) {
            $FileUrl64 = $FileUrl64 -replace '{VERSION}', $ForceVersionNumber
        }

        # File Download and Product Version
        DownloadFile -Url $FileUrl -TempPath $FileDownloadTempPath
        $ProductVersion = Get-ProductVersion -FileDownloadTempPath $FileDownloadTempPath -ForceVersionNumber $ForceVersionNumber
        Write-Debug "Product version: $ProductVersion"

        # 64-bit File Processing
        if ($FileUrl64) {
            DownloadFile -Url $FileUrl64 -TempPath $FileDownloadTempPath64 -Is64Bit $true
            $ProductVersion64 = Get-ProductVersion -FileDownloadTempPath $FileDownloadTempPath64 -ForceVersionNumber $ForceVersionNumber
        }

        # Nuspec Version and Checksums
        $NuspecContent = Get-Content $NuspecPath -Raw
        $NuspecVersion = ([regex]::Match($NuspecContent, '<version>(.*?)<\/version>')).Groups[1].Value

        $NewChecksum = (Get-FileHash -Algorithm SHA256 $FileDownloadTempPath).Hash
        $NewChecksum64 = if ($FileUrl64) { (Get-FileHash -Algorithm SHA256 $FileDownloadTempPath64).Hash } else { $null }

        # Define the match pattern for checksum in ChocolateyInstall.ps1
        $ChocolateyInstallPattern = '(?i)(?<=(checksum\s*=\s*)["''])(.*?)(?=["''])'
        $ChocolateyInstallPattern64 = '(?i)(?<=(checksum64\s*=\s*)["''])(.*?)(?=["''])'

        # Extract the current checksum from ChocolateyInstall.ps1
        $ChocolateyInstallContent = Get-Content $InstallScriptPath -Raw
        $ChocolateyInstallChecksumMatches = [regex]::Match($ChocolateyInstallContent, $ChocolateyInstallPattern)
        $ChocolateyInstallChecksum = $ChocolateyInstallChecksumMatches.Value.Trim("'")

        # Extract the current checksum from ChocolateyInstall.ps1 for 64-bit
        $ChocolateyInstallChecksumMatches64 = [regex]::Match($ChocolateyInstallContent, $ChocolateyInstallPattern64)
        $ChocolateyInstallChecksum64 = $ChocolateyInstallChecksumMatches64.Value.Trim("'")

        # Verification Patterns
        $VerificationPattern = '(?i)(?<=checksum:\s*)\w+'
        $VerificationPattern64 = '(?i)(?<=checksum64:\s*)\w+'

        # Extract the current checksum from VERIFICATION.txt if the file exists
        if (Test-Path $VerificationPath) {
            $VerificationContent = Get-Content $VerificationPath -Raw
            $VerificationChecksumMatches = [regex]::Match($VerificationContent, $VerificationPattern)
            $VerificationChecksum = $VerificationChecksumMatches.Value

            if ($FileUrl64) {
                $VerificationChecksumMatches64 = [regex]::Match($VerificationContent, $VerificationPattern64)
                $VerificationChecksum64 = $VerificationChecksumMatches64.Value
            }
        }

        Write-Output "Product version: $ProductVersion"

        if ($ProductVersion64) {
            Write-Output "Product version (64-bit): $ProductVersion64"
        }

        # Check if the 64-bit URL is specified and the product versions are different
        if ($FileUrl64 -and $ProductVersion -ne $ProductVersion64) {
            throw "Product versions are different. Please ensure that the 32-bit and 64-bit versions are the same."
        }

        Write-Output "Nuspec version: $NuspecVersion"

        # If the version is the same as the ignore version, skip the comparison
        if ($ProductVersion -eq $IgnoreVersion) {
            Write-Output "IgnoreVersion specified, ignoring comparison for version: $IgnoreVersion"
            return
        }

        Write-Output "New checksum: $NewChecksum"
        if ($FileUrl64) {
            Write-Output "New checksum (64-bit): $NewChecksum64"
        }

        Write-Output "ChocolateyInstall.ps1 checksum: $ChocolateyInstallChecksum"

        if ($FileUrl64) {
            Write-Output "ChocolateyInstall.ps1 checksum (64-bit): $ChocolateyInstallChecksum64"
        }

        # Output for default checksum
        if (Test-Path $VerificationPath) {
            Write-Output "Verification checksum: $VerificationChecksum"
            if ($FileUrl64) {
                Write-Output "Verification checksum (64-bit): $VerificationChecksum64"
            }
        }

        # Validate version strings
        if ($ProductVersion -match '^\d+(\.\d+){1,3}$' -and $NuspecVersion -match '^\d+(\.\d+){1,3}$') {
            Write-Debug "Version strings are valid."

            # Compare versions, compare ChocolateyInstall.ps1 checksum, and compare VERIFICATION.txt checksum if $VerificationPath is set and the file exists
            Write-Output "Comparing versions and checksums..."
            $comparisonResult = PerformComparison -ProductVersion $ProductVersion -NuspecVersion $NuspecVersion -ChocolateyInstallChecksum $ChocolateyInstallChecksum -NewChecksum $NewChecksum -ChocolateyInstallChecksum64 $ChocolateyInstallChecksum64 -NewChecksum64 $NewChecksum64 -VerificationPath $VerificationPath -VerificationChecksum $VerificationChecksum -VerificationChecksum64 $VerificationChecksum64 -FileUrl64 $FileUrl64
            if ($comparisonResult["OverallComparison"]) {
                Write-Output "Version or checksum is different. Updating package..."

                # Update version in nuspec file
                Write-Output "Updating version in nuspec file..."

                # Update the <version> tag
                $nuspecVersionResult = UpdateFileContent -FilePath $NuspecPath -Pattern '(?<=<version>).*?(?=<\/version>)' -Replacement $ProductVersion
                HandleUpdateResult -Result $nuspecVersionResult -SuccessMessage "Updated version in nuspec file" -FailureMessage "Failed to update version in nuspec file`n$nuspecVersionResult"

                # ChocolateyInstall.ps1
                # Update version
                Write-Output "Updating version in ChocolateyInstall.ps1 script (if it exists)..."
                $chocolateyInstallVersionPattern = '(?i)(?<=(version\s*=\s*)["''])(.*?)(?=["''])'
                $chocolateyInstallVersionResult = UpdateFileContent -FilePath $InstallScriptPath -Pattern $chocolateyInstallVersionPattern -Replacement $ProductVersion
                HandleUpdateResult -Result $chocolateyInstallVersionResult -SuccessMessage "Updated version in ChocolateyInstall.ps1 script" -FailureMessage "Did not update version in ChocolateyInstall.ps1 script, ignore error if not used`nMessage: $chocolateyInstallVersionResult"

                # ChocolateyInstall.ps1
                # Update url if ForceVersionNumber is not set, unless DownloadUrlScrapePattern or DownloadUrlScrapePattern64 is set
                if (-not $ForceVersionNumber -or $DownloadUrlScrapePattern -or $DownloadUrlScrapePattern64) {
                    Write-Output "Updating URL in ChocolateyInstall.ps1 script (if it exists)..."
                    $chocolateyInstallUrlPattern = '(?i)(?<=(url\s*=\s*)["''])(.*?)(?=["''])'
                    $chocolateyInstallUrlResult = UpdateFileContent -FilePath $InstallScriptPath -Pattern $chocolateyInstallUrlPattern -Replacement $FileUrl
                    HandleUpdateResult -Result $chocolateyInstallUrlResult -SuccessMessage "Updated URL in ChocolateyInstall.ps1 script" -FailureMessage "Did not update version in ChocolateyInstall.ps1 script, ignore error if not used`nMessage: $chocolateyInstallUrlResult"
                } else {
                    Write-Output "Version replacement is occurring in ChocolateyInstall.ps1 script. Skipping URL update in script."
                }

                # ChocolateyInstall.ps1
                # Update checksum
                Write-Output "Updating checksum in ChocolateyInstall.ps1 script..."
                $chocolateyInstallResult = UpdateFileContent -FilePath $InstallScriptPath -Pattern $ChocolateyInstallPattern -Replacement $NewChecksum
                HandleUpdateResult -Result $chocolateyInstallResult -SuccessMessage "Updated checksum in ChocolateyInstall.ps1 script" -FailureMessage "Did not update version in ChocolateyInstall.ps1 script, ignore if not used`nMessage: $chocolateyInstallResult"

                # ChocolateyInstall.ps1
                # Update url64 and checksum64
                if ($FileUrl64 -and $FileDownloadTempPath64) {
                    # Update the url64 or url64bit in ChocolateyInstall.ps1 if ForceVersionNumber is not set
                    if (-not $ForceVersionNumber) {
                        Write-Output "Updating url64 or url64bit in ChocolateyInstall.ps1 script (if it exists)..."
                        $chocolateyInstallUrl64Pattern = '(?i)(?<=(url64bit\s*=\s*)["''])(.*?)(?=["''])|(?i)(?<=(url64\s*=\s*)["''])(.*?)(?=["''])'
                        $chocolateyInstallUrl64Result = UpdateFileContent -FilePath $InstallScriptPath -Pattern $chocolateyInstallUrl64Pattern -Replacement $FileUrl64
                        HandleUpdateResult -Result $chocolateyInstallUrl64Result -SuccessMessage "Updated URL64 in ChocolateyInstall.ps1 script" -FailureMessage "Did not update URL64 in ChocolateyInstall.ps1 script, ignore error if not used`nMessage: $chocolateyInstallUrl64Result"
                    } else {
                        Write-Output "Version replacement is occurring in ChocolateyInstall.ps1 script. Skipping URL64 update in script."
                    }

                    # Update the checksum64 in ChocolateyInstall.ps1
                    Write-Output "Updating checksum64 in ChocolateyInstall.ps1 script (if it exists)..."
                    $chocolateyInstallResult64 = UpdateFileContent -FilePath $InstallScriptPath -Pattern $ChocolateyInstallPattern64 -Replacement $NewChecksum64
                    HandleUpdateResult -Result $chocolateyInstallResult64 -SuccessMessage "Updated checksum64 in ChocolateyInstall.ps1 script" -FailureMessage "Did not update checksum64 in ChocolateyInstall.ps1 script, ignore error if not used`Message: $chocolateyInstallResult64"
                }

                # VERIFICATION.txt
                # Check whether $VerificationPath and if set, check if it exists or not
                if (Test-Path $VerificationPath) {
                    # checksum
                    Write-Debug "Verification path is set and file exists. Updating checksum in verification file: $VerificationPath."
                    $verificationResult = UpdateFileContent -FilePath $VerificationPath -Pattern $VerificationPattern -Replacement $NewChecksum
                    HandleUpdateResult -Result $verificationResult -SuccessMessage "Updated checksum in verification file" -FailureMessage "Did not update checksum in verification file, ignore error if not used`nMessage: $verificationResult"

                    # checksum64
                    if ($FileUrl64) {
                        if (Test-Path $VerificationPath) {
                            Write-Debug "Verification path is set and file exists. Updating checksum64 in verification file: $VerificationPath."
                            $verificationResult64 = UpdateFileContent -FilePath $VerificationPath -Pattern $VerificationPattern64 -Replacement $NewChecksum64
                            HandleUpdateResult -Result $verificationResult64 -SuccessMessage "Updated checksum64 in verification file" -FailureMessage "Did not update checksum64 in verification file, ignore error if not used`nMessage: $verificationResult64"
                        }
                    }
                }

                # Write the new version to the console
                Write-Output "Updated to version $ProductVersion"

                # Delete any nupkg files in the package folder if it exists
                $nupkgFiles = Get-ChildItem -Path $ScriptPath -Filter "$PackageName.*.nupkg" -File
                if ($nupkgFiles) {
                    foreach ($nupkgFile in $nupkgFiles) {
                        Write-Output "Deleting old nupkg file: $nupkgFile"
                        Remove-Item -Path $nupkgFile.FullName -Force
                    }
                }

                # Run 'choco pack' to create the nupkg file
                Write-Output "Creating nupkg file..."
                choco pack

                # Send an alert if enabled
                Write-Debug "Sending alert..."
                SendAlert -Subject "$PackageName Package Updated" -Message "$PackageName has been updated to version $ProductVersion. It is now ready for testing." -Alert $Alert

                # If the destination path is specified, move the downloaded file to the specified destination
                if ($FileDestinationPath) {
                    Write-Debug "Moving file `"${FileDownloadTempPath}`" to `"${FileDestinationPath}`""
                    try {
                        Move-Item $FileDownloadTempPath -Destination $FileDestinationPath -Force
                    } catch {
                        throw "Failed to move file `"${FileDownloadTempPath}`" to `"${FileDestinationPath}`" with error: $_"
                    }
                }

                # If the destination path is specified, move the downloaded file to the specified destination for 64-bit
                if ($FileUrl64 -and $FileDestinationPath64) {
                    Write-Debug "Moving file `"${FileDownloadTempPath64}`" to `"${FileDestinationPath64}`""
                    try {
                        Move-Item $FileDownloadTempPath64 -Destination $FileDestinationPath64 -Force
                    } catch {
                        throw "Failed to move file `"${FileDownloadTempPath64}`" to `"${FileDestinationPath64}`" with error: $_"
                    }
                }
            } else {
                # Package is up to date
                Write-Output "No update needed. No alert sent."
            }
        } else {
            # Invalid version format
            Write-Output "Invalid version format. Skipping update."

            # Send an alert if enabled
            Write-Debug "Sending package error alert..."
            SendAlert -Subject "$PackageName Package Error" -Message "$PackageName detected an invalid version format. Please check the update script and files." -Alert $Alert
        }
    } catch {
        # Send an alert if enabled
        Write-Debug "Sending package error alert..."
        SendAlert -Subject "$PackageName Package Error" -Message "$PackageName had an error when checking for updates. Please check the update script and files.<br><br><strong>Error:</strong> $_" -Alert $Alert

        # Write the error to the console
        Write-Warning "An error occurred: $_"
        Write-Warning "Line number : $($_.InvocationInfo.ScriptLineNumber)"
    } finally {
        CleanupFileDownload
        Write-Output "Done."

        # Return to the original directory
        Pop-Location
    }
}

Write-Output ""
# SIG # Begin signature block
# MIIhGAYJKoZIhvcNAQcCoIIhCTCCIQUCAQExDzANBglghkgBZQMEAgIFADCBiQYK
# KwYBBAGCNwIBBKB7MHkwNAYKKwYBBAGCNwIBHjAmAgMBAAAEEB/MO2BZSwhOtyTS
# xil+81ECAQACAQACAQACAQACAQAwQTANBglghkgBZQMEAgIFAAQwt1I5lFVaQyav
# UxuekACsDQeQ5GOGjhx8SyFwnlg5E9jLiSfx68mJqsZbWGTCic1PoIIHZDCCA1kw
# ggLfoAMCAQICEA+4p0C5FY0DUUO8WdnwQCkwCgYIKoZIzj0EAwMwYTELMAkGA1UE
# BhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2lj
# ZXJ0LmNvbTEgMB4GA1UEAxMXRGlnaUNlcnQgR2xvYmFsIFJvb3QgRzMwHhcNMjEw
# NDI5MDAwMDAwWhcNMzYwNDI4MjM1OTU5WjBkMQswCQYDVQQGEwJVUzEXMBUGA1UE
# ChMORGlnaUNlcnQsIEluYy4xPDA6BgNVBAMTM0RpZ2lDZXJ0IEdsb2JhbCBHMyBD
# b2RlIFNpZ25pbmcgRUNDIFNIQTM4NCAyMDIxIENBMTB2MBAGByqGSM49AgEGBSuB
# BAAiA2IABLu0rCelSA2iU1+PLoE+L1N2uAiUopqqiouYtbHw/CoVu7mzpSIv/WrA
# veJVaGBrlzTBZlNxI/wa1cogDwJAoqNKWkajkVMrlfID6aum04d2L+dkn541UfzD
# YzV4duT4d6OCAVcwggFTMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYEFJtf
# sDa6nQauGSe9wKAiwIuLOHftMB8GA1UdIwQYMBaAFLPbSKT5ocXYrjZBzBFjaWIp
# vEvGMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcDAzB2BggrBgEF
# BQcBAQRqMGgwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBA
# BggrBgEFBQcwAoY0aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0
# R2xvYmFsUm9vdEczLmNydDBCBgNVHR8EOzA5MDegNaAzhjFodHRwOi8vY3JsMy5k
# aWdpY2VydC5jb20vRGlnaUNlcnRHbG9iYWxSb290RzMuY3JsMBwGA1UdIAQVMBMw
# BwYFZ4EMAQMwCAYGZ4EMAQQBMAoGCCqGSM49BAMDA2gAMGUCMHi9SZVlcQHQRldo
# ZQ5oqdw2CMHu/dSO20BlPw3/k6/CrmOGo37LtJFaeOwHA2cHfAIxAOefH/EHW6w0
# xji8taVQzubqOH4+eZDkpFurAg3oB/xWplqK3bNQst3y+mZ0ntAWYzCCBAMwggOJ
# oAMCAQICEAExw+sKUABDj0yZt5afTZQwCgYIKoZIzj0EAwMwZDELMAkGA1UEBhMC
# VVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTwwOgYDVQQDEzNEaWdpQ2VydCBH
# bG9iYWwgRzMgQ29kZSBTaWduaW5nIEVDQyBTSEEzODQgMjAyMSBDQTEwHhcNMjQw
# MzA3MDAwMDAwWhcNMjUwMzA4MjM1OTU5WjBvMQswCQYDVQQGEwJVUzERMA8GA1UE
# CBMIT2tsYWhvbWExETAPBgNVBAcTCE11c2tvZ2VlMRwwGgYDVQQKExNBc2hlciBT
# b2x1dGlvbnMgSW5jMRwwGgYDVQQDExNBc2hlciBTb2x1dGlvbnMgSW5jMHYwEAYH
# KoZIzj0CAQYFK4EEACIDYgAExsP0nyCZ1QtY7aXin+tdZVcF0uPHJJjRpjVVgUmb
# 3iKJeKapvWBSAbroBouKIP9+Qoz197aNbZCSOBQsWX53SUyTu1Trvwku7ksL+eQh
# bJvnRJ20UqF566z5KbniyLrAo4IB8zCCAe8wHwYDVR0jBBgwFoAUm1+wNrqdBq4Z
# J73AoCLAi4s4d+0wHQYDVR0OBBYEFNdgDYHKEBunNDYgivfxKeS4YX0/MD4GA1Ud
# IAQ3MDUwMwYGZ4EMAQQBMCkwJwYIKwYBBQUHAgEWG2h0dHA6Ly93d3cuZGlnaWNl
# cnQuY29tL0NQUzAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMw
# gasGA1UdHwSBozCBoDBOoEygSoZIaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0Rp
# Z2lDZXJ0R2xvYmFsRzNDb2RlU2lnbmluZ0VDQ1NIQTM4NDIwMjFDQTEuY3JsME6g
# TKBKhkhodHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRHbG9iYWxHM0Nv
# ZGVTaWduaW5nRUNDU0hBMzg0MjAyMUNBMS5jcmwwgY4GCCsGAQUFBwEBBIGBMH8w
# JAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBXBggrBgEFBQcw
# AoZLaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0R2xvYmFsRzND
# b2RlU2lnbmluZ0VDQ1NIQTM4NDIwMjFDQTEuY3J0MAkGA1UdEwQCMAAwCgYIKoZI
# zj0EAwMDaAAwZQIxAJHtFqbIBTSZ6AiYEyHsjjlZ7treTZfTSPiyyr8KAKBPKVXt
# B2859Jj8A3c9lEXrLgIwGTu2YV8DhFy9OqIDwkCZfoYH8oMo1LRtYhYZtVzkr3WF
# er8mkmAdOyNbW/DI0pZPMYIY+TCCGPUCAQEweDBkMQswCQYDVQQGEwJVUzEXMBUG
# A1UEChMORGlnaUNlcnQsIEluYy4xPDA6BgNVBAMTM0RpZ2lDZXJ0IEdsb2JhbCBH
# MyBDb2RlIFNpZ25pbmcgRUNDIFNIQTM4NCAyMDIxIENBMQIQATHD6wpQAEOPTJm3
# lp9NlDANBglghkgBZQMEAgIFAKCBjDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG
# 9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIB
# FTA/BgkqhkiG9w0BCQQxMgQwJ5+ngv65QHzK70qDGKH0fj96cQCuEFybpF/tULT7
# 4Vz0KUtzvabSI2P7jroPOI1wMAsGByqGSM49AgEFAARnMGUCMQDc+ot5iNPZcz3N
# LS5/kkXF8ztnE3L+KfK1wEDYBqRzHO0Re61nAyA4qd9p0456Gs8CMEthTDRGzQOF
# 7oNn+dLLaMnoo1qYFKrBaHUqlBluU3yD14mz7zbdbpd+nuw+celBE6GCF2Awghdc
# BgorBgEEAYI3AwMBMYIXTDCCF0gGCSqGSIb3DQEHAqCCFzkwghc1AgEDMQ8wDQYJ
# YIZIAWUDBAICBQAwgYcGCyqGSIb3DQEJEAEEoHgEdjB0AgEBBglghkgBhv1sBwEw
# QTANBglghkgBZQMEAgIFAAQwx9gKheT3gikrkCfO34YAekMvVEhuKkztipz48I93
# 08e4FRC2TPXFjuBZQdPfmZPWAhBUgvIqN0sbGON1pE/PEGhtGA8yMDI0MDYwOTIy
# NDkzM1qgghMJMIIGwjCCBKqgAwIBAgIQBUSv85SdCDmmv9s/X+VhFjANBgkqhkiG
# 9w0BAQsFADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4x
# OzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGlt
# ZVN0YW1waW5nIENBMB4XDTIzMDcxNDAwMDAwMFoXDTM0MTAxMzIzNTk1OVowSDEL
# MAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMSAwHgYDVQQDExdE
# aWdpQ2VydCBUaW1lc3RhbXAgMjAyMzCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCC
# AgoCggIBAKNTRYcdg45brD5UsyPgz5/X5dLnXaEOCdwvSKOXejsqnGfcYhVYwamT
# EafNqrJq3RApih5iY2nTWJw1cb86l+uUUI8cIOrHmjsvlmbjaedp/lvD1isgHMGX
# lLSlUIHyz8sHpjBoyoNC2vx/CSSUpIIa2mq62DvKXd4ZGIX7ReoNYWyd/nFexAaa
# PPDFLnkPG2ZS48jWPl/aQ9OE9dDH9kgtXkV1lnX+3RChG4PBuOZSlbVH13gpOWvg
# eFmX40QrStWVzu8IF+qCZE3/I+PKhu60pCFkcOvV5aDaY7Mu6QXuqvYk9R28mxyy
# t1/f8O52fTGZZUdVnUokL6wrl76f5P17cz4y7lI0+9S769SgLDSb495uZBkHNwGR
# Dxy1Uc2qTGaDiGhiu7xBG3gZbeTZD+BYQfvYsSzhUa+0rRUGFOpiCBPTaR58ZE2d
# D9/O0V6MqqtQFcmzyrzXxDtoRKOlO0L9c33u3Qr/eTQQfqZcClhMAD6FaXXHg2TW
# dc2PEnZWpST618RrIbroHzSYLzrqawGw9/sqhux7UjipmAmhcbJsca8+uG+W1eEQ
# E/5hRwqM/vC2x9XH3mwk8L9CgsqgcT2ckpMEtGlwJw1Pt7U20clfCKRwo+wK8REu
# ZODLIivK8SgTIUlRfgZm0zu++uuRONhRB8qUt+JQofM604qDy0B7AgMBAAGjggGL
# MIIBhzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAK
# BggrBgEFBQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwHwYD
# VR0jBBgwFoAUuhbZbU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFKW27xPn783Q
# ZKHVVqllMaPe1eNJMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRpZ2lj
# ZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBp
# bmdDQS5jcmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRwOi8v
# b2NzcC5kaWdpY2VydC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRzLmRp
# Z2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3Rh
# bXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggIBAIEa1t6gqbWYF7xwjU+KPGic
# 2CX/yyzkzepdIpLsjCICqbjPgKjZ5+PF7SaCinEvGN1Ott5s1+FgnCvt7T1Ijrhr
# unxdvcJhN2hJd6PrkKoS1yeF844ektrCQDifXcigLiV4JZ0qBXqEKZi2V3mP2yZW
# K7Dzp703DNiYdk9WuVLCtp04qYHnbUFcjGnRuSvExnvPnPp44pMadqJpddNQ5EQS
# viANnqlE0PjlSXcIWiHFtM+YlRpUurm8wWkZus8W8oM3NG6wQSbd3lqXTzON1I13
# fXVFoaVYJmoDRd7ZULVQjK9WvUzF4UbFKNOt50MAcN7MmJ4ZiQPq1JE3701S88lg
# IcRWR+3aEUuMMsOI5ljitts++V+wQtaP4xeR0arAVeOGv6wnLEHQmjNKqDbUuXKW
# fpd5OEhfysLcPTLfddY2Z1qJ+Panx+VPNTwAvb6cKmx5AdzaROY63jg7B145WPR8
# czFVoIARyxQMfq68/qTreWWqaNYiyjvrmoI1VygWy2nyMpqy0tg6uLFGhmu6F/3E
# d2wVbK6rr3M66ElGt9V/zLY4wNjsHPW2obhDLN9OTH0eaHDAdwrUAuBcYLso/zjl
# UlrWrBciI0707NMX+1Br/wd3H3GXREHJuEbTbDJ8WC9nR2XlG3O2mflrLAZG70Ee
# 8PBf4NvZrZCARK+AEEGKMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipeWzAN
# BgkqhkiG9w0BAQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQg
# SW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2Vy
# dCBUcnVzdGVkIFJvb3QgRzQwHhcNMjIwMzIzMDAwMDAwWhcNMzcwMzIyMjM1OTU5
# WjBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNV
# BAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1w
# aW5nIENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxoY1BkmzwT1y
# SVFVxyUDxPKRN6mXUaHW0oPRnkyibaCwzIP5WvYRoUQVQl+kiPNo+n3znIkLf50f
# ng8zH1ATCyZzlm34V6gCff1DtITaEfFzsbPuK4CEiiIY3+vaPcQXf6sZKz5C3GeO
# 6lE98NZW1OcoLevTsbV15x8GZY2UKdPZ7Gnf2ZCHRgB720RBidx8ald68Dd5n12s
# y+iEZLRS8nZH92GDGd1ftFQLIWhuNyG7QKxfst5Kfc71ORJn7w6lY2zkpsUdzTYN
# XNXmG6jBZHRAp8ByxbpOH7G1WE15/tePc5OsLDnipUjW8LAxE6lXKZYnLvWHpo9O
# dhVVJnCYJn+gGkcgQ+NDY4B7dW4nJZCYOjgRs/b2nuY7W+yB3iIU2YIqx5K/oN7j
# PqJz+ucfWmyU8lKVEStYdEAoq3NDzt9KoRxrOMUp88qqlnNCaJ+2RrOdOqPVA+C/
# 8KI8ykLcGEh/FDTP0kyr75s9/g64ZCr6dSgkQe1CvwWcZklSUPRR8zZJTYsg0ixX
# NXkrqPNFYLwjjVj33GHek/45wPmyMKVM1+mYSlg+0wOI/rOP015LdhJRk8mMDDtb
# iiKowSYI+RQQEgN9XyO7ZONj4KbhPvbCdLI/Hgl27KtdRnXiYKNYCQEoAA6EVO7O
# 6V3IXjASvUaetdN2udIOa5kM0jO0zbECAwEAAaOCAV0wggFZMBIGA1UdEwEB/wQI
# MAYBAf8CAQAwHQYDVR0OBBYEFLoW2W1NhS9zKXaaL3WMaiCPnshvMB8GA1UdIwQY
# MBaAFOzX44LScV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUE
# DDAKBggrBgEFBQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6
# Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2VydHMu
# ZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDww
# OjA4oDagNIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3Rl
# ZFJvb3RHNC5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMA0G
# CSqGSIb3DQEBCwUAA4ICAQB9WY7Ak7ZvmKlEIgF+ZtbYIULhsBguEE0TzzBTzr8Y
# +8dQXeJLKftwig2qKWn8acHPHQfpPmDI2AvlXFvXbYf6hCAlNDFnzbYSlm/EUExi
# HQwIgqgWvalWzxVzjQEiJc6VaT9Hd/tydBTX/6tPiix6q4XNQ1/tYLaqT5Fmniye
# 4Iqs5f2MvGQmh2ySvZ180HAKfO+ovHVPulr3qRCyXen/KFSJ8NWKcXZl2szwcqMj
# +sAngkSumScbqyQeJsG33irr9p6xeZmBo1aGqwpFyd/EjaDnmPv7pp1yr8THwcFq
# cdnGE4AJxLafzYeHJLtPo0m5d2aR8XKc6UsCUqc3fpNTrDsdCEkPlM05et3/JWOZ
# Jyw9P2un8WbDQc1PtkCbISFA0LcTJM3cHXg65J6t5TRxktcma+Q4c6umAU+9Pzt4
# rUyt+8SVe+0KXzM5h0F4ejjpnOHdI/0dKNPH+ejxmF/7K9h+8kaddSweJywm228V
# ex4Ziza4k9Tm8heZWcpw8De/mADfIBZPJ/tgZxahZrrdVcA6KYawmKAr7ZVBtzrV
# FZgxtGIJDwq9gdkT/r+k0fNX2bwE+oLeMt8EifAAzV3C+dAjfwAL5HYCJtnwZXZC
# pimHCUcr5n8apIUP/JiW9lVUKx+A+sDyDivl1vupL0QVSucTDh3bNzgaoSv27dZ8
# /DCCBY0wggR1oAMCAQICEA6bGI750C3n79tQ4ghAGFowDQYJKoZIhvcNAQEMBQAw
# ZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQ
# d3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBS
# b290IENBMB4XDTIyMDgwMTAwMDAwMFoXDTMxMTEwOTIzNTk1OVowYjELMAkGA1UE
# BhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2lj
# ZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MIICIjAN
# BgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAv+aQc2jeu+RdSjwwIjBpM+zCpyUu
# ySE98orYWcLhKac9WKt2ms2uexuEDcQwH/MbpDgW61bGl20dq7J58soR0uRf1gU8
# Ug9SH8aeFaV+vp+pVxZZVXKvaJNwwrK6dZlqczKU0RBEEC7fgvMHhOZ0O21x4i0M
# G+4g1ckgHWMpLc7sXk7Ik/ghYZs06wXGXuxbGrzryc/NrDRAX7F6Zu53yEioZldX
# n1RYjgwrt0+nMNlW7sp7XeOtyU9e5TXnMcvak17cjo+A2raRmECQecN4x7axxLVq
# GDgDEI3Y1DekLgV9iPWCPhCRcKtVgkEy19sEcypukQF8IUzUvK4bA3VdeGbZOjFE
# mjNAvwjXWkmkwuapoGfdpCe8oU85tRFYF/ckXEaPZPfBaYh2mHY9WV1CdoeJl2l6
# SPDgohIbZpp0yt5LHucOY67m1O+SkjqePdwA5EUlibaaRBkrfsCUtNJhbesz2cXf
# SwQAzH0clcOP9yGyshG3u3/y1YxwLEFgqrFjGESVGnZifvaAsPvoZKYz0YkH4b23
# 5kOkGLimdwHhD5QMIR2yVCkliWzlDlJRR3S+Jqy2QXXeeqxfjT/JvNNBERJb5RBQ
# 6zHFynIWIgnffEx1P2PsIV/EIFFrb7GrhotPwtZFX50g/KEexcCPorF+CiaZ9eRp
# L5gdLfXZqbId5RsCAwEAAaOCATowggE2MA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0O
# BBYEFOzX44LScV1kTN8uZz/nupiuHA9PMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1R
# i6enIZ3zbcgPMA4GA1UdDwEB/wQEAwIBhjB5BggrBgEFBQcBAQRtMGswJAYIKwYB
# BQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0
# cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENB
# LmNydDBFBgNVHR8EPjA8MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20v
# RGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMBEGA1UdIAQKMAgwBgYEVR0gADAN
# BgkqhkiG9w0BAQwFAAOCAQEAcKC/Q1xV5zhfoKN0Gz22Ftf3v1cHvZqsoYcs7IVe
# qRq7IviHGmlUIu2kiHdtvRoU9BNKei8ttzjv9P+Aufih9/Jy3iS8UgPITtAq3vot
# Vs/59PesMHqai7Je1M/RQ0SbQyHrlnKhSLSZy51PpwYDE3cnRNTnf+hZqPC/Lwum
# 6fI0POz3A8eHqNJMQBk1RmppVLC4oVaO7KTVPeix3P0c2PR3WlxUjG/voVA9/HYJ
# aISfb8rbII01YBwCA8sgsKxYoA5AY8WYIsGyWfVVa88nq2x2zm8jLfR+cWojayL/
# ErhULSd+2DrZ8LaHlv1b0VysGMNNn3O3AamfV6peKOK5lDGCA4YwggOCAgEBMHcw
# YzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQD
# EzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGlu
# ZyBDQQIQBUSv85SdCDmmv9s/X+VhFjANBglghkgBZQMEAgIFAKCB4TAaBgkqhkiG
# 9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTI0MDYwOTIyNDkz
# M1owKwYLKoZIhvcNAQkQAgwxHDAaMBgwFgQUZvArMsLCyQ+CXc6qisnGTxmcz0Aw
# NwYLKoZIhvcNAQkQAi8xKDAmMCQwIgQg0vbkbe10IszR1EBXaEE2b4KK2lWarjMW
# r00amtQMeCgwPwYJKoZIhvcNAQkEMTIEMG635Dqqsfw4i+04cbi+ITDOsjSZiUhF
# dNVsfS4RXRfd3roduTcYQxg3ZZvVxGfZ2zANBgkqhkiG9w0BAQEFAASCAgAqIjcY
# YCy0iWmPFydk7vK8xIKWmIG9s4W+67scgvREm7gJg7t46/YcRYjNXPFGqzn+SUql
# sxCez0Kefc+vlNUXmPwwVJHiyOzkhETL4hVheNrRC6XjsccDZPEUnMdVEvSOrjaH
# 3Ha6nPjny82I5mRTwQWk84ev8risk7Irv0ajlpJhAHkzcZfMEl3+ZCEEITRYWx/r
# 3tlndDVIzuHuiIYlI3nJ5/kS+zXbZdvpxV1KgVB8MeoEZ6+aHq2mwMvRfg2EA1M3
# hz2hKACXXTXdjBPMyyKUqMRUUux7pbWe5Wky3x2FFUIamVZxY5BPy7E860mLZvSM
# v1T6qqbltT1AVP15TXUH98e8vnQsxkInNSF0r20CgLdS2fssHh72xEKAS03tM60w
# Qv5B3D7CRpC7P5/CYM+S250cN6veMFIWf+L2NLEYASRMFMQG2on52NOzFBTunYsf
# fqeeOHTRXURP6pBA6R45McfwJBMRED0dROtxgsw2g5GSINI9MZoxnhKKQjbmEE1t
# 4MxLOWayQ4bzeou8XEiJ+ltXCyUddgOU3ijmok/iixpEn+6Kta5SouAojs/GCe23
# O8Wazv6tXLgE96ad7hBfKzbNUSvi/jTbUU8bo+iVLX1BzT9YszOhyEx4oIOFuZQB
# 7URDE25Uz+RrH5TNy46dlzc+j34SY9SqESdc1Q==
# SIG # End signature block
