# ScraperAPI Setup Instructions

This package uses ScraperAPI to fetch the latest Antigravity download URL from the JavaScript-rendered download page.

## Setting up the GitHub Secret

1. **Get a ScraperAPI key:**
   - Sign up at https://www.scraperapi.com/
   - Get your API key from the dashboard

2. **Add the secret to your GitHub repository:**
   - Go to your GitHub repository: https://github.com/targed/chocolatey-projects
   - Navigate to `Settings` → `Secrets and variables` → `Actions`
   - Click `New repository secret`
   - Name: `SCRAPERAPI_KEY`
   - Value: Your ScraperAPI key
   - Click `Add secret`

3. **For local testing:**
   - Set the environment variable before running the script:
   ```powershell
   $env:SCRAPERAPI_KEY = "your_api_key_here"
   .\updateNew.ps1
   ```

## How it works

1. `fetchAG.ps1` - Fetches the Antigravity download page using ScraperAPI with JavaScript rendering enabled
2. The script parses the HTML to extract the download URL for `Antigravity.exe`
3. `updateNew.ps1` - Calls `fetchAG.ps1` and uses the returned URL to update the Chocolatey package

## Fallback behavior

If the ScraperAPI fetch fails or the URL cannot be extracted, the script will fall back to a hardcoded URL and display a warning.

## Files

- `fetchAG.ps1` - PowerShell script to fetch the download URL
- `fetchAG.sh` - Bash version (for WSL/Linux environments)
- `updateNew.ps1` - Main update script that calls fetchAG.ps1
- `antigravity_response.html` - Cached HTML response (generated when script runs)
