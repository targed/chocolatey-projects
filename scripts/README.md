# Chocolatey Package Discovery Tools

This directory contains a suite of tools for discovering highly-rated Windows applications on GitHub that do not yet exist in the Chocolatey Community Repository, as well as scaffolding new Chocolatey packages automatically.

## Requirements
Ensure you have Python 3 installed. Install the necessary packages via:
```sh
pip install -r requirements.txt
```

## Setup
The script relies on the GitHub API. Unauthenticated requests are heavily rate-limited. To ensure you don't hit rate limits quickly, set the `GITHUB_TOKEN` environment variable with a personal access token.

```sh
# On Windows (PowerShell)
$env:GITHUB_TOKEN="your_personal_access_token"

# On Linux/macOS
export GITHUB_TOKEN="your_personal_access_token"
```

## Discovery Script (`find_missing_packages.py`)

This script queries GitHub for high-starred repositories (filtering by Windows topics or specific languages), checks their latest release assets for Windows executables/archives, and queries the Chocolatey v2 API to filter out packages that already exist.

### Usage
Run the script to generate `results.json`:

```sh
python find_missing_packages.py --limit 50
```

#### Arguments
* `--limit <number>`: Number of top GitHub repositories to check (default: 50).
* `--lang <language>`: Filter search by language (e.g., `C#`, `C++`, `Rust`, `Go`). Optional.
* `--out <filename>`: The name of the output JSON file (default: `results.json`).
* `--generate <github_url>`: Skips discovery and directly scaffolds a Chocolatey package from the provided GitHub URL.

## Scaffolding Packages

If you find a repository that you'd like to package, you can generate a base Chocolatey template structure for it:

```sh
python find_missing_packages.py --generate "https://github.com/owner/repository_name"
```

This command will:
1. Fetch repository details via the GitHub API (description, author, etc.).
2. Create a new directory named after the repository (lowercased) at the current working path.
3. Utilize the files in `scripts/templates/` to generate `[package].nuspec`, `updateNew.ps1`, and `tools/chocolateyinstall.ps1`.
4. Automatically replace placeholders (like `{{PACKAGE_ID}}`, `{{AUTHOR}}`) in the generated files.

*Note: This command generates the folder in your current working directory. You may want to run it from the root of your project.*

## Visualization (`index.html`)

After generating `results.json` from the discovery script, you can open `index.html` in your web browser to view a formatted, sortable table of the discovered packages. It displays the package name, GitHub stars, a calculated "Ease of Installation" score, and relevant links.

*If your browser blocks loading local JSON files due to CORS policies (like Chrome often does), you can run a simple local web server to view it:*
```sh
python -m http.server
```
Then navigate to `http://localhost:8000/index.html`.
