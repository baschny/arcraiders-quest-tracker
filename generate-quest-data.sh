#!/bin/bash
# Generate and inject quest data directly into index.html
# This script extracts quest metadata and detects blueprint rewards

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
QUESTS_DIR="$SCRIPT_DIR/../quests"
TEMP_FILE="$SCRIPT_DIR/.quests-data.tmp.json"
HTML_FILE="$SCRIPT_DIR/index.html"

echo "Generating quest data from $QUESTS_DIR..."

# Generate quest data JSON
jq -s 'map({
  id, 
  name: .name.en, 
  trader, 
  previousQuestIds: (.previousQuestIds // []), 
  nextQuestIds: (.nextQuestIds // []), 
  hasBlueprint: ((.rewardItemIds // []) | map(.itemId) | any(test("_blueprint$")))
}) | sort_by(.id)' "$QUESTS_DIR"/*.json > "$TEMP_FILE"

QUEST_COUNT=$(jq 'length' "$TEMP_FILE")
BLUEPRINT_COUNT=$(jq 'map(select(.hasBlueprint)) | length' "$TEMP_FILE")
BLUEPRINT_IDS=$(jq -c 'map(select(.hasBlueprint) | .id)' "$TEMP_FILE")

# Compact the JSON for embedding
QUEST_DATA=$(jq -c '.' "$TEMP_FILE")

# Update index.html by replacing the QUEST_DATA line
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s|const QUEST_DATA = \[.*\];|const QUEST_DATA = $QUEST_DATA;|" "$HTML_FILE"
else
    # Linux
    sed -i "s|const QUEST_DATA = \[.*\];|const QUEST_DATA = $QUEST_DATA;|" "$HTML_FILE"
fi

# Clean up temp file
rm "$TEMP_FILE"

echo "✓ Updated $HTML_FILE with quest data"
echo "  Total quests: $QUEST_COUNT"
echo "  Blueprint quests: $BLUEPRINT_COUNT"
echo "  Blueprint quest IDs: $BLUEPRINT_IDS"
echo ""
echo "Quest data has been automatically injected into index.html"
