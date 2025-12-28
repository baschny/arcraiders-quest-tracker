#!/bin/bash
# Generate quest-tracker/quests-data.json from the parent directory's quest JSON files
# This script extracts quest metadata and detects blueprint rewards

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
QUESTS_DIR="$SCRIPT_DIR/../quests"
OUTPUT_FILE="$SCRIPT_DIR/quests-data.json"

echo "Generating quest data from $QUESTS_DIR..."

jq -s 'map({
  id, 
  name: .name.en, 
  trader, 
  previousQuestIds: (.previousQuestIds // []), 
  nextQuestIds: (.nextQuestIds // []), 
  hasBlueprint: ((.rewardItemIds // []) | map(.itemId) | any(test("_blueprint$")))
}) | sort_by(.id)' "$QUESTS_DIR"/*.json > "$OUTPUT_FILE"

QUEST_COUNT=$(jq 'length' "$OUTPUT_FILE")
BLUEPRINT_COUNT=$(jq 'map(select(.hasBlueprint)) | length' "$OUTPUT_FILE")
BLUEPRINT_IDS=$(jq -c 'map(select(.hasBlueprint) | .id)' "$OUTPUT_FILE")

echo "✓ Generated $OUTPUT_FILE"
echo "  Total quests: $QUEST_COUNT"
echo "  Blueprint quests: $BLUEPRINT_COUNT"
echo "  Blueprint quest IDs: $BLUEPRINT_IDS"
echo ""
echo "Next steps:"
echo "1. Review the generated quests-data.json file"
echo "2. Update the QUESTS array in index.html by copying the content"
echo "3. Update the BLUEPRINT_QUESTS Set in index.html with the blueprint IDs shown above"
