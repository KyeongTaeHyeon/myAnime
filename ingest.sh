#!/usr/bin/env bash

set -euo pipefail

API_BASE="${API_BASE:-http://localhost:8082}"
EMAIL="${EMAIL:-dev@example.com}"
PASSWORD="${PASSWORD:-devpassword123!}"
DISPLAY_NAME="${DISPLAY_NAME:-dev}"

register_payload=$(cat <<JSON
{"email":"$EMAIL","password":"$PASSWORD","displayName":"$DISPLAY_NAME"}
JSON
)

login_payload=$(cat <<JSON
{"email":"$EMAIL","password":"$PASSWORD"}
JSON
)

echo "Logging in..."
login_res=$(curl -s -X POST "$API_BASE/api/auth/login" -H "Content-Type: application/json" -d "$login_payload" || true)

token=$(echo "$login_res" | ruby -rjson -e 'begin; puts JSON.parse(STDIN.read)["accessToken"].to_s; rescue; puts ""; end')

if [[ -z "$token" ]]; then
  echo "User not found. Registering..."
  curl -s -X POST "$API_BASE/api/auth/register" -H "Content-Type: application/json" -d "$register_payload" >/dev/null || true
  login_res=$(curl -s -X POST "$API_BASE/api/auth/login" -H "Content-Type: application/json" -d "$login_payload")
  token=$(echo "$login_res" | ruby -rjson -e 'begin; puts JSON.parse(STDIN.read)["accessToken"].to_s; rescue; puts ""; end')
fi

if [[ -z "$token" ]]; then
  echo "Failed to obtain access token"
  exit 1
fi

echo "Ingesting AniList season..."
curl -s -X POST "$API_BASE/api/admin/ingest/anilist/season?year=2025&season=WINTER&page=1&perPage=50" \
  -H "Authorization: Bearer $token" >/dev/null

echo "Ingesting quotes (Naruto)..."
curl -s -X POST "$API_BASE/api/admin/ingest/animechan/quotes?anime=Naruto" \
  -H "Authorization: Bearer $token" >/dev/null

echo "Ingesting news..."
curl -s -X POST "$API_BASE/api/admin/ingest/newsapi?query=anime%20OR%20manga" \
  -H "Authorization: Bearer $token" >/dev/null

echo "Done"
