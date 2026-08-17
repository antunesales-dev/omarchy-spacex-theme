#!/bin/bash
# Pull upcoming SpaceX flights from Launch Library 2 and cache a small JSON
# the clock calendar can read even if a later request fails.
set -euo pipefail

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/omarchy-spacex"
cache="$cache_dir/launches.json"
mkdir -p "$cache_dir"

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

url="https://ll.thespacedevs.com/2.2.0/launch/upcoming/?lsp__id=121&limit=25"
if ! curl -fsSL -A "omarchy-spacex-theme" --max-time 15 "$url" -o "$tmp"; then
  if [[ -f $cache ]]; then
    cat "$cache"
    exit 0
  fi
  echo '{"fetched":false,"launches":[]}'
  exit 1
fi

python3 - "$tmp" "$cache" <<'PY'
import json
import sys
from datetime import datetime, timezone

src, dest = sys.argv[1], sys.argv[2]
raw = json.load(open(src, encoding="utf-8"))
out = []
for item in raw.get("results") or []:
    net = item.get("net") or ""
    try:
        when = datetime.fromisoformat(net.replace("Z", "+00:00")).astimezone()
    except Exception:
        continue
    name = item.get("name") or "Launch"
    short = name.split(" | ", 1)[-1]
    pad = (item.get("pad") or {}).get("name") or ""
    loc = ((item.get("pad") or {}).get("location") or {}).get("name") or ""
    out.append({
        "key": when.strftime("%Y-%m-%d"),
        "net": net,
        "local": when.strftime("%a %d %b  %H:%M"),
        "name": name,
        "short": short,
        "status": ((item.get("status") or {}).get("abbrev") or ""),
        "pad": pad,
        "location": loc,
        "year": when.year,
        "month": when.month - 1,
    })
payload = {"fetched": True, "launches": out}
text = json.dumps(payload)
open(dest, "w", encoding="utf-8").write(text)
print(text)
PY
