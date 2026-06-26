import requests
import json
import os
import argparse
import urllib.parse
import shutil
import re

GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN")
HEADERS = {"Authorization": f"token {GITHUB_TOKEN}", "Accept": "application/vnd.github.v3+json"} if GITHUB_TOKEN else {"Accept": "application/vnd.github.v3+json"}

def search_github_repos(limit=50, lang=None):
    # Search for repositories that have a lot of stars, filtering for windows
    query = "stars:>1000"
    if lang:
        query += f" language:{lang}"
    else:
        query += " (topic:windows OR topic:desktop)"

    url = f"https://api.github.com/search/repositories?q={urllib.parse.quote(query)}&sort=stars&order=desc&per_page={limit}"
    response = requests.get(url, headers=HEADERS)
    response.raise_for_status()
    return response.json().get('items', [])

def check_windows_assets(repo):
    url = f"https://api.github.com/repos/{repo['full_name']}/releases/latest"
    response = requests.get(url, headers=HEADERS)
    if response.status_code == 200:
        release = response.json()
        assets = release.get('assets', [])

        windows_assets = []
        for asset in assets:
            name = asset['name'].lower()
            if name.endswith('.msi') or name.endswith('.exe') or name.endswith('.zip') or name.endswith('.appx') or name.endswith('.msix'):
                if 'win' in name or '64' in name or '86' in name or 'setup' in name:
                    windows_assets.append(asset)
                elif name.endswith('.msi') or name.endswith('.exe'):
                    windows_assets.append(asset)

        return windows_assets
    return []

def calculate_ease(assets):
    if not assets:
        return "Unknown"

    for asset in assets:
        name = asset['name'].lower()
        if name.endswith('.msi'):
            return "Very Easy (MSI)"

    for asset in assets:
        name = asset['name'].lower()
        if name.endswith('.exe'):
            return "Easy (EXE)"

    for asset in assets:
        name = asset['name'].lower()
        if name.endswith('.appx') or name.endswith('.msix'):
            return "Moderate (Appx/MSIX)"

    for asset in assets:
        name = asset['name'].lower()
        if name.endswith('.zip'):
            return "Moderate (ZIP)"

    return "Unknown"

def check_chocolatey(package_name):
    url = f"https://community.chocolatey.org/api/v2/Search()?$filter=IsLatestVersion&searchTerm='{urllib.parse.quote(package_name)}'&targetFramework=''&includePrerelease=false"
    response = requests.get(url)
    if response.status_code == 200:
        # Check if the exact package name or something very similar exists in the feed
        if f"<title type=\"text\">{package_name.lower()}</title>" in response.text.lower():
            return True
        if "CCR.Website.V2FeedPackage" in response.text:
            # We got results, simple heuristic: if it returned results, we assume a match might exist
            # Better check if the exact id matches
            if f"Id='{package_name.lower()}'" in response.text.lower():
                return True
    return False

def generate_package(repo_url):
    # Parse URL to get owner and repo
    match = re.search(r"github\.com/([^/]+)/([^/]+)", repo_url)
    if not match:
        print(f"Invalid GitHub URL: {repo_url}")
        return

    owner, repo_name = match.groups()
    repo_name = repo_name.replace('.git', '')

    # Fetch repo info
    api_url = f"https://api.github.com/repos/{owner}/{repo_name}"
    response = requests.get(api_url, headers=HEADERS)
    if response.status_code != 200:
        print(f"Failed to fetch repo info for {owner}/{repo_name}")
        return

    repo_info = response.json()
    desc = repo_info.get('description', '') or ''
    author = repo_info.get('owner', {}).get('login', 'Unknown')
    package_id = repo_name.lower()

    # Check if package folder exists
    if os.path.exists(package_id):
        print(f"Directory {package_id} already exists.")
        return

    # Ensure templates exist
    if not os.path.exists('scripts/templates') or not os.path.exists('scripts/templates/template.nuspec'):
        print("Templates directory or files not found. Please create them first.")
        return

    print(f"Generating package {package_id}...")

    # Copy template folder structure
    os.makedirs(package_id)
    os.makedirs(f"{package_id}/tools")

    # Read and replace template contents
    with open('scripts/templates/template.nuspec', 'r') as f:
        nuspec_content = f.read()

    nuspec_content = nuspec_content.replace('{{PACKAGE_ID}}', package_id)
    nuspec_content = nuspec_content.replace('{{PACKAGE_NAME}}', repo_name)
    nuspec_content = nuspec_content.replace('{{AUTHOR}}', author)
    nuspec_content = nuspec_content.replace('{{URL}}', repo_url)
    nuspec_content = nuspec_content.replace('{{DESCRIPTION}}', desc)

    with open(f"{package_id}/{package_id}.nuspec", 'w') as f:
        f.write(nuspec_content)

    with open('scripts/templates/updateNew.ps1', 'r') as f:
        update_content = f.read()

    update_content = update_content.replace('{{PACKAGE_ID}}', package_id)
    update_content = update_content.replace('{{GITHUB_REPO}}', f"{owner}/{repo_name}")

    with open(f"{package_id}/updateNew.ps1", 'w') as f:
        f.write(update_content)

    with open('scripts/templates/tools/chocolateyinstall.ps1', 'r') as f:
        install_content = f.read()

    install_content = install_content.replace('{{PACKAGE_ID}}', package_id)

    with open(f"{package_id}/tools/chocolateyinstall.ps1", 'w') as f:
        f.write(install_content)

    print(f"Successfully generated template for {package_id} in /{package_id}")

def main():
    parser = argparse.ArgumentParser(description="Find missing Chocolatey packages from GitHub")
    parser.add_argument("--limit", type=int, default=50, help="Number of GitHub repos to check")
    parser.add_argument("--lang", type=str, help="Language to filter by (e.g. C#)")
    parser.add_argument("--out", type=str, default="results.json", help="Output JSON file")
    parser.add_argument("--generate", type=str, help="GitHub URL to generate a package template for")

    args = parser.parse_args()

    if args.generate:
        generate_package(args.generate)
        return

    if not GITHUB_TOKEN:
        print("Warning: GITHUB_TOKEN environment variable not set. You may hit rate limits.")

    print(f"Searching top {args.limit} repos (Language: {args.lang or 'Any'})...")
    repos = search_github_repos(limit=args.limit, lang=args.lang)

    results = []

    for repo in repos:
        name = repo['name']
        print(f"Checking {name}...")

        # Check if it has windows releases
        assets = check_windows_assets(repo)
        if not assets:
            continue

        # Check if it exists on Chocolatey
        if check_chocolatey(name):
            print(f"  -> {name} already on Chocolatey")
            continue

        ease = calculate_ease(assets)

        results.append({
            "name": name,
            "url": repo['html_url'],
            "stars": repo['stargazers_count'],
            "description": repo['description'],
            "ease_of_installation": ease,
            "download_url": assets[0]['browser_download_url'] if assets else None
        })
        print(f"  -> Found potential package: {name} ({ease})")

    with open(args.out, 'w') as f:
        json.dump(results, f, indent=2)

    print(f"\nSaved {len(results)} potential packages to {args.out}")

if __name__ == "__main__":
    main()
