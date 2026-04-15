#!/usr/bin/env bash

set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:3000}"
COMPARE_PATH="${COMPARE_PATH:-/compare?repo=octokit/rest.js&from=22.0.0&to=latest}"
HOME_RUNS="${HOME_RUNS:-5}"
COMPARE_RUNS="${COMPARE_RUNS:-5}"

measure_url() {
  local label="$1"
  local url="$2"
  local runs="$3"
  local timings_file

  timings_file="$(mktemp)"

  echo "$label"
  echo "  url: $url"

  for run in $(seq 1 "$runs"); do
    local timings
    local starttransfer
    local total

    timings="$(curl -sS -o /dev/null -w '%{time_starttransfer} %{time_total}' "$url")"
    starttransfer="${timings%% *}"
    total="${timings##* }"

    printf '  run %d  starttransfer=%ss  total=%ss\n' "$run" "$starttransfer" "$total"
    printf '%s\n' "$timings" >> "$timings_file"
  done

  awk '
    BEGIN {
      min_start = -1
      min_total = -1
    }
    {
      start_sum += $1
      total_sum += $2

      if (min_start < 0 || $1 < min_start) min_start = $1
      if ($1 > max_start) max_start = $1

      if (min_total < 0 || $2 < min_total) min_total = $2
      if ($2 > max_total) max_total = $2
    }
    END {
      printf "  avg    starttransfer=%.6fs  total=%.6fs\n", start_sum / NR, total_sum / NR
      printf "  range  starttransfer=%.6f-%.6fs  total=%.6f-%.6fs\n\n", min_start, max_start, min_total, max_total
    }
  ' "$timings_file"

  rm -f "$timings_file"
}

asset_size() {
  local path="$1"

  if [[ -f "$path" ]]; then
    printf '  %8d bytes  %s\n' "$(wc -c < "$path" | tr -d ' ')" "$path"
  else
    printf '  missing         %s\n' "$path"
  fi
}

echo "Octochangelog demo benchmark"
echo "base url: $BASE_URL"
echo

measure_url "Landing page timings" "$BASE_URL/" "$HOME_RUNS"
measure_url "Compare page timings" "$BASE_URL$COMPARE_PATH" "$COMPARE_RUNS"

echo "Asset sizes"
asset_size "public/packs/js/generated/CompareFiltersStandalone.js"
asset_size "public/packs/js/client0.js"
asset_size "public/packs/js/generated/OctochangelogCompareResultsPage.js"
asset_size "public/packs/css/application.css"
