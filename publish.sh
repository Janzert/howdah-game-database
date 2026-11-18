#!/usr/bin/env bash
# Publishes the game database from arimaa.com's archive files into this
# directory: imports them all, appends the newly seen games to seen.txt,
# packs a base when asked (--new-base) or when there's none, rebuilds the
# deltas and writes base.json. Then run upload.sh and commit base.json
# and seen.txt.
#
#   ./publish.sh ARCHIVE_DIR [--new-base] [--cap PCT] [-j N]
#
# ARCHIVE_DIR holds the allgames*.zip files. howdah-db is built at the
# commit in howdah-rev (into .tools/), or set HOWDAH_DB to a build of it.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
if [ $# -lt 1 ]; then
  sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
  exit 2
fi
rev=$(tr -d '[:space:]' < "$here/howdah-rev")
tool=${HOWDAH_DB:-$here/.tools/$rev/bin/howdah-db}
if [ ! -x "$tool" ]; then
  cargo install --locked --git https://github.com/Janzert/howdah --rev "$rev" \
    --root "$here/.tools/$rev" howdah-db
fi
"$tool" publish "$here" "$@"
