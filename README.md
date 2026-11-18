# Howdah game database

[arimaa.com](http://arimaa.com/)'s game archive, packaged as a database
for [Howdah](https://github.com/Janzert/howdah), the Arimaa desktop
client. Howdah's Games panel downloads it from this repository's
[`current` release](https://github.com/Janzert/howdah-game-database/releases/tag/current)
to search and open the games offline, and later fetches only the games
added since.

## Where the games come from

Every game here is from the game archive arimaa.com publishes (the
`allgames` files under `http://arimaa.com/arimaa/download/gameData/`),
played on arimaa.com's gameroom by its players and bots since 2002. All
credit for the games goes to arimaa.com and the people who played them.
This repository only repackages them. Each game keeps its players,
titles, countries, ratings, event, time control, times, result and
moves (stored in Howdah's compact form, which writes a setup's pieces
in square order; a move list that can't be replayed is kept as it
was); of the gameroom's event log, only the move times are kept.

Serving the download from GitHub keeps Howdah's users from each
fetching the archive from arimaa.com. If you want the original files,
please take them from arimaa.com, and only the ones you need.

The scripts here are under the MIT license (`LICENSE`). The game records
are arimaa.com's, not covered by that license.

## What's in the release

- `base.json`, the manifest: when the newest games were first
  published, how many games there are, and each file's name, size,
  SHA-256 and what it holds.
- `howdah-games-<time>.db.zst`, the base: the whole archive as of then,
  a SQLite database in Howdah's format (without its search indexes),
  compressed with zstd. About 143 MB for some 425,000 games.
- `howdah-games-<time>-since-<time>.db.zst`, the deltas: the games
  first published after a time, up to the newest. Each publish rebuilds
  them, starting 1, 2, 4, 8, … publishes back and at the base. A
  database that reached some time takes the delta starting closest
  before it; a new one takes the base and the delta after it.

The format and the reasons for it are in Howdah's
[`docs/DATABASE.md`](https://github.com/Janzert/howdah/blob/main/docs/DATABASE.md)
("Step 5"). A file's names carry times and never change, so the
manifest always names files that are there.

## What's kept here

Everything a publish needs besides the archive files themselves:

- `base.json`, the manifest the release has now. A publish builds on it
  (the base stays the same until a new one is asked for).
- `seen.txt`, when each game was first published: arimaa.com game ids
  in blocks under `@<time>` (Unix seconds). Each publish appends a
  block. The deltas are made from it.
- `howdah-rev`, the Howdah commit whose `howdah-db` builds the files.

## Publishing

1. Download the archive's `allgames*.zip` files into a directory (only
   the new or changed ones each time).
2. `./publish.sh ARCHIVE_DIR` imports them all, appends the new games
   to `seen.txt`, rebuilds the deltas and writes `base.json`. With no
   new games it writes nothing. `--new-base` packs a new base too, which
   is needed only when the deltas grow large next to it or to pick up
   corrections to older games; `--cap PCT` (10 by default) is how large
   next to the base the oldest deltas may grow. It builds `howdah-db`
   at `howdah-rev` with `cargo install` (or set `HOWDAH_DB` to a build).
3. `./upload.sh` brings the `current` release in line with `base.json`:
   the new files first, then `base.json`, then it deletes the files no
   longer named. It needs `gh`, logged in.
4. Commit `base.json` and `seen.txt` (and `howdah-rev` if it changed).
