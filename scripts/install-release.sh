#!/bin/bash

set -euo pipefail

REPOSITORY="${1:-taywrobel/xenon-edge-macos}"
API="https://api.github.com/repos/$REPOSITORY/releases/latest"
TMP="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP"
}
trap cleanup EXIT

python3 - "$API" "$TMP" <<'PY'
import json
import pathlib
import sys
import urllib.request

api, destination = sys.argv[1], pathlib.Path(sys.argv[2])
with urllib.request.urlopen(api) as response:
    release = json.load(response)

assets = {asset["name"]: asset["browser_download_url"] for asset in release["assets"]}
archives = sorted(name for name in assets if name.startswith("Xeneon-Touch-") and name.endswith(".zip"))
if len(archives) != 1 or "SHA256SUMS" not in assets:
    raise SystemExit("Release does not contain exactly one Xeneon Touch ZIP and SHA256SUMS")

for name in (archives[0], "SHA256SUMS"):
    urllib.request.urlretrieve(assets[name], destination / name)
PY

(
  cd "$TMP"
  shasum -a 256 -c SHA256SUMS
  unzip -q Xeneon-Touch-*.zip
)

PACKAGE="$(find "$TMP" -maxdepth 1 -type d -name 'Xeneon-Touch-*' -print -quit)"
"$PACKAGE/Install.command"
