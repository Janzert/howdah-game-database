#!/usr/bin/env bash
# Brings the `current` release in line with base.json: uploads the files
# it names that the release lacks, then base.json, then deletes the
# release's files base.json no longer names. In that order, an app
# reading the release always finds the files its manifest names.
# Needs gh, logged in with write access to this repository.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
cd "$here"
release=current
named=$(python3 -c '
import json
m = json.load(open("base.json"))
for p in [m["base"]] + m.get("deltas", []):
    print(p["file"])
')
if ! gh release view "$release" > /dev/null 2>&1; then
  gh release create "$release" --title "Game database" --latest \
    --notes "arimaa.com's game archive packaged for Howdah. The files change as new games are published; see the README."
fi
have=$(gh release view "$release" --json assets -q '.assets[].name')
for f in $named; do
  if ! grep -qxF "$f" <<< "$have"; then
    [ -f "$f" ] || { echo "$f is named in base.json but isn't here" >&2; exit 1; }
    echo "uploading $f"
    gh release upload "$release" "$f"
  fi
done
echo "uploading base.json"
gh release upload "$release" base.json --clobber
for f in $have; do
  if [ "$f" != base.json ] && ! grep -qxF "$f" <<< "$named"; then
    echo "deleting $f"
    gh release delete-asset "$release" "$f" --yes
  fi
done
echo "done; commit base.json and seen.txt"
