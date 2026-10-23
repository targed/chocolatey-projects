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

## Local Web UI (`app.py`)

To view a formatted, sortable table of the discovered packages and easily generate packages via your browser, you can run the local web server:

```sh
python app.py
```

Then navigate to `http://localhost:8000`.
This web UI uses the `results.json` file generated from `find_missing_packages.py` and provides a "Generate Package" button next to each result to automatically scaffold it using the provided templates.
