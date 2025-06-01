# chocolatey-projects

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) <!-- Assuming MIT License from the LICENSE file -->

## Description

This project contains a collection of PowerShell scripts designed to maintain and update Chocolatey packages. It automates the update process for several applications by checking for new versions, downloading them, updating checksums, and modifying the necessary Chocolatey package files.

## Features

- **Automated Package Updates**: Scripts automatically check for and prepare updates for configured packages.
- **Centralized Update Script**: `UpdateAll.ps1` allows for updating all automatically managed packages with a single command.
- **Modular Design**: Uses a core updater script (`Chocolatey-Package-Updater.ps1`) that is configurable for each package.
- **Version Scraping**: Capable of fetching the latest version information from GitHub releases or by scraping download pages.
- **Checksum Management**: Automatically calculates and updates checksums in package files.
- **Nuspec & Install Script Updates**: Modifies `.nuspec` and `ChocolateyInstall.ps1` files with new version details, URLs, and checksums.

## Packages Managed

This repository helps manage the following Chocolatey packages:

### Automatically Updated

These packages are updated automatically using the scripts in this repository:

- ChatGPT (Unofficial `lencx/ChatGPT` version)
- Claude
- Cursor
- LM-Studio
- NoFWL
- TumblThree
- Jan

### Manually Updated

These packages currently require manual intervention for updates:

- Grayjay
- Vexcode
- Vexcode Pro

### In Progress

Development is underway to automate updates for these packages:

- JMARS
- Windsurf

## Project Structure

Key files and directories in this project:

- `README.md`: This file.
- `LICENSE`: The license for this project.
- `UpdateAll.ps1`: The main script to trigger updates for all automatically managed packages.
- `Chocolatey-Package-Updater.ps1`: The core PowerShell script responsible for the logic of updating a Chocolatey package. It handles version checking, file downloading, checksum calculation, and updating package metadata.
- `[PackageName]/`: Each directory contains the files for a specific Chocolatey package.
  - `updateNew.ps1`: A package-specific script that configures parameters (e.g., package name, download URL, GitHub repository for version checking) and then calls the `UpdateChocolateyPackage` function from `Chocolatey-Package-Updater.ps1`.
  - `[PackageName].nuspec`: The Chocolatey package specification file. This file contains metadata about the package, such as its ID, version, author, and dependencies.
  - `tools/ChocolateyInstall.ps1`: The PowerShell script that Chocolatey runs to install the package. This script typically downloads the application installer and runs it.
  - 'tools/ChocolateyUninstall.ps1': The PowerShell script that Chocolatey runs to uninstall the package. This script typically removes the installed application.

## Getting Started

### Prerequisites

- Windows Operating System
- PowerShell
- [Chocolatey](https://chocolatey.org/install) installed on your system.

### Setup

1.  **Clone the repository**:
    ```powershell
    git clone https://github.com/USERNAME/chocolatey-projects.git # Replace USERNAME with the actual GitHub username/organization
    cd chocolatey-projects
    ```
2.  **Review Configuration**:
    Individual `updateNew.ps1` scripts within each package directory may contain specific configurations (like GitHub repository URLs for version checking). Ensure these are appropriate for your use.

## Usage

### Updating All Automated Packages

To update all packages listed in the "Automatically Updated" section, run the `UpdateAll.ps1` script from the root of the project directory:

```powershell
# Ensure your PowerShell execution policy allows running local scripts
# Set-ExecutionPolicy Bypass -Scope Process -Force (if needed, for the current session)

.\UpdateAll.ps1
```

This script will iterate through the configured package directories and execute their respective `updateNew.ps1` scripts.

### Updating a Single Package

To update a specific package:

1.  Navigate to the package's directory (e.g., `cd ChatGPT_Unofficial`).
2.  Run its `updateNew.ps1` script:

    ```powershell
    .\updateNew.ps1
    ```

## How it Works

The update process is driven by a combination of scripts:

1.  **`UpdateAll.ps1`**: This top-level script serves as an orchestrator. It calls the individual `updateNew.ps1` script for each package that is designated for automatic updates.

2.  **`[PackageName]/updateNew.ps1`**: Each package has its own `updateNew.ps1` script. This script is responsible for:

    - Defining package-specific variables (e.g., `PackageName`, `FileUrl`, `GitHubRepoUrl`).
    - Importing the `UpdateChocolateyPackage` function from the `Chocolatey-Package-Updater.ps1` script.
    - Calling `UpdateChocolateyPackage` with the package-specific parameters.

3.  **`Chocolatey-Package-Updater.ps1`**: This is the core script that contains the `UpdateChocolateyPackage` function. This function performs the heavy lifting:
    - **Version Checking**: It determines the latest version of the software. This can be done by:
      - Querying the GitHub API for the latest release of a specified repository (if `GitHubRepoUrl` is provided).
      - Scraping a webpage for version information (if `ScrapeUrl` and `ScrapePattern` are provided).
      - Extracting the version from the filename or metadata of a downloaded file.
    - **Comparison**: It compares the latest found version with the current version listed in the package's `.nuspec` file.
    - **Download & Verification**: If a new version is detected:
      - It downloads the software installer from the specified `FileUrl` (which can include a `{VERSION}` placeholder).
      - It calculates the SHA256 checksum of the downloaded file.
    - **Package File Updates**:
      - The `.nuspec` file is updated with the new version number.
      - The `tools/ChocolateyInstall.ps1` script is updated with the new download URL (if version-dependent) and the new checksum.
      - If a `tools/VERIFICATION.txt` file exists, it's also updated with the new checksum.
    - **Cleanup**: Temporary files are removed.
    - **Alerts & Pushing (Optional)**: The script has capabilities for sending notifications (e.g., via Mailjet, if configured) and automatically pushing updated packages to the Chocolatey community repository (if `AutoPush` is enabled and configured).

For detailed information on creating and maintaining Chocolatey packages, refer to the [official Chocolatey documentation](https://docs.chocolatey.org/en-us/create/create-packages).

## Contributing

This project is primarily for personal use in managing Chocolatey packages. However, suggestions, bug reports, or improvements are welcome. Please feel free to open an issue or submit a pull request.

When contributing, please ensure:

- Scripts are well-commented.
- Changes are tested.
- The general structure and approach of the project are maintained.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
