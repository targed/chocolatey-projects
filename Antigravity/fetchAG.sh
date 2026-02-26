#!/bin/bash

# Set your ScraperAPI key here or pass it as an environment variable
API_KEY="${SCRAPERAPI_KEY:-your_scraperapi_key_here}"

# Build the ScraperAPI URL
TARGET_URL="https://antigravity.google/download"
# Enable JavaScript rendering with render=true
# Add wait_for=5000 to wait 5 seconds for JS to execute (in milliseconds)
SCRAPER_URL="http://api.scraperapi.com?api_key=${API_KEY}&url=${TARGET_URL}&render=true&wait_for=5000"

echo "Fetching URL: ${SCRAPER_URL}"

# Call ScraperAPI
response=$(curl -s "${SCRAPER_URL}")

# Check if curl was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to fetch URL"
    exit 1
fi

echo "Response received (first 500 characters):"
echo "$response" | head -c 500
echo -e "\n\n---\n"

# Check if response is JSON or HTML
if echo "$response" | jq empty 2>/dev/null; then
    echo "Response is valid JSON:"
    echo "$response" | jq '.'
else
    echo "Response is HTML, parsing with grep/sed..."
    # Save to local directory for easier parsing and inspection
    OUTPUT_FILE="antigravity_response.html"
    echo "$response" > "$OUTPUT_FILE"
    echo "HTML saved to: $OUTPUT_FILE"
    
    # Example: Extract download links (adjust pattern based on actual HTML structure)
    echo "Looking for download links..."
    grep -oP 'href="\K[^"]*\.(exe|msi|dmg|pkg)[^"]*' "$OUTPUT_FILE" || \
    grep -oP 'https?://[^"]*\.(exe|msi|dmg|pkg)' "$OUTPUT_FILE"
    
    # You may need to adjust the regex pattern based on the actual HTML structure
    # To see the full HTML: cat $OUTPUT_FILE
fi
