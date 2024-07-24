#!/bin/bash

# Check if the callsign argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <callsign>"
    exit 1
fi

CALLSIGN="$1"
SANITIZED_CALLSIGN=$(echo "$CALLSIGN" | sed 's/[\/:*?"<>|]/_/g')
URL="https://www.mcmc.gov.my/en/legal/registers/register-of-apparatus-assignments-search?keyword=${CALLSIGN}&type=AARadio"
OUTPUT_FILE="response_${SANITIZED_CALLSIGN}.html"
FORMATTED_FILE="formatted_${SANITIZED_CALLSIGN}.txt"

# Make the HTTP request and save the response to a file
curl -A "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1" \
     "$URL" -o "$OUTPUT_FILE"

# Check if the request was successful
if [ $? -ne 0 ]; then
    echo "Error retrieving data"
    rm -f "$OUTPUT_FILE" "$FORMATTED_FILE"  # Clean up temporary files
    exit 1
fi

# Extract and format the required data
grep -oP '<td>\K[^<]+' "$OUTPUT_FILE" | awk 'NR%5{printf "%s,", $0; next} {print $0}' > "$FORMATTED_FILE"

# Output the formatted data
if [ -s "$FORMATTED_FILE" ]; then
    echo "Formatted data:"
    cat "$FORMATTED_FILE"
else
    echo "No data found or error in formatting"
fi

# Clean up temporary files
rm -f "$OUTPUT_FILE" "$FORMATTED_FILE"

