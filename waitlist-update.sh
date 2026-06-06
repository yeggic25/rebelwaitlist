#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.env"

POSTHOG_RESPONSE=$(curl -s -X POST "https://app.posthog.com/api/projects/372936/query" \
  -H "Authorization: Bearer $POSTHOG_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "kind": "HogQLQuery",
      "query": "select count(*) from persons where properties.Approved = false"
    }
  }')

RAW_COUNT=$(echo "$POSTHOG_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['results'][0][0])")
TOTAL=$((RAW_COUNT + 273))

MESSAGE="Rebel Audio Waitlist Update 📋
✅ Total waitlisted: $TOTAL"

curl -s -X POST "https://slack.com/api/chat.postMessage" \
  -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"channel\": \"#lattice-rebel\",
    \"text\": $(python3 -c "import sys, json; print(json.dumps(sys.argv[1]))" "$MESSAGE")
  }"

echo "Done. Posted total: $TOTAL"
