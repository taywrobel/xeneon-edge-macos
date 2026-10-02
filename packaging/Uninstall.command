#!/bin/bash

set -euo pipefail

LABEL="com.github.xeneon-edge.touch"
APP="$HOME/Applications/Xeneon Touch.app"
BIN="$APP/Contents/MacOS/xeneon-touch"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
DOMAIN="gui/$(id -u)"

launchctl bootout "$DOMAIN" "$PLIST" 2>/dev/null || true
if [[ -x "$BIN" ]]; then
  while read -r pid command; do
    if [[ "$command" == "$BIN"* ]]; then
      kill "$pid"
    fi
  done < <(ps ax -o pid=,command=)
fi
rm -f "$PLIST"
rm -rf "$APP"

echo "Uninstalled Xeneon Touch."
