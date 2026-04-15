#!/usr/bin/env bash
set -euo pipefail

url="${1:-${BENCH_URL:-http://127.0.0.1:3000/}}"
runs="${RUNS:-5}"

for i in $(seq 1 "$runs"); do
  curl -s -o /dev/null -w "run=${i} ttfb=%{time_starttransfer} total=%{time_total}\n" "$url"
done
