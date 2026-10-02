#!/bin/bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
SOURCE_APP="$ROOT/Xeneon Touch.app"
DEST_APP="$HOME/Applications/Xeneon Touch.app"

if [[ ! -d "$SOURCE_APP" ]]; then
  echo "Xeneon Touch.app is missing from this release." >&2
  exit 1
fi

mkdir -p "$HOME/Applications"
rm -rf "$DEST_APP"
ditto "$SOURCE_APP" "$DEST_APP"
xattr -dr com.apple.quarantine "$DEST_APP" 2>/dev/null || true
"$ROOT/register-service.sh" "$DEST_APP"

echo
echo "Installed: $DEST_APP"
echo "Enable Xeneon Touch in:"
echo "  System Settings > Privacy & Security > Input Monitoring"
echo "  System Settings > Privacy & Security > Accessibility"
open "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent"
