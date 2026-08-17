#!/bin/bash
# Pull previous and upcoming SpaceX flights from Launch Library 2.
set -euo pipefail

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/omarchy-spacex"
cache="$cache_dir/launches.json"
mkdir -p "$cache_dir"

upcoming=$(mktemp)
previous=$(mktemp)
trap 'rm -f "$upcoming" "$previous"' EXIT

ua="omarchy-spacex-theme"
ok=0
curl -fsSL -A "$ua" --max-time 15 \
  "https://ll.thespacedevs.com/2.2.0/launch/upcoming/?lsp__id=121&limit=25" \
  -o "$upcoming" && ok=$((ok + 1)) || true
curl -fsSL -A "$ua" --max-time 15 \
  "https://ll.thespacedevs.com/2.2.0/launch/previous/?lsp__id=121&limit=40" \
  -o "$previous" && ok=$((ok + 1)) || true

if (( ok == 0 )); then
  if [[ -f $cache ]]; then
    cat "$cache"
    exit 0
  fi
  echo '{"fetched":false,"launches":[]}'
  exit 1
fi

python3 - "$upcoming" "$previous" "$cache" <<'PY'
import json
import sys
from datetime import datetime, timezone

def load_results(path):
    try:
        raw = json.load(open(path, encoding="utf-8"))
    except Exception:
        return []
    return raw.get("results") or []

def normalize(item, now):
    net = item.get("net") or ""
    try:
        when = datetime.fromisoformat(net.replace("Z", "+00:00")).astimezone()
    except Exception:
        return None
    name = item.get("name") or "Launch"
    pad = (item.get("pad") or {}).get("name") or ""
    loc = ((item.get("pad") or {}).get("location") or {}).get("name") or ""
    return {
        "key": when.strftime("%Y-%m-%d"),
        "net": net,
        "local": when.strftime("%a %d %b  %H:%M"),
        "name": name,
        "short": name.split(" | ", 1)[-1],
        "status": ((item.get("status") or {}).get("abbrev") or ""),
        "pad": pad,
        "location": loc,
        "year": when.year,
        "month": when.month - 1,
        "past": when < now,
    }

now = datetime.now().astimezone()
seen = set()
out = []
for path in (sys.argv[1], sys.argv[2]):
    for item in load_results(path):
        row = normalize(item, now)
        if not row or row["net"] in seen:
            continue
        seen.add(row["net"])
        out.append(row)
out.sort(key=lambda row: row["net"])
payload = {"fetched": True, "launches": out}
text = json.dumps(payload)
open(sys.argv[3], "w", encoding="utf-8").write(text)
print(text)
PY
