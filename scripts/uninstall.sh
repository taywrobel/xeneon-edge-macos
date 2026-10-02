#!/bin/bash

set -euo pipefail

LABEL="com.github.xeneon-edge.touch"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
APP="$HOME/Applications/Xeneon Touch.app"
DOMAIN="gui/$(id -u)"

launchctl bootout "$DOMAIN" "$PLIST" 2>/dev/null || true
BIN="$APP/Contents/MacOS/xeneon-touch"
while read -r pid command; do
  if [[ "$command" == "$BIN"* ]]; then
    kill "$pid"
  fi
done < <(ps ax -o pid=,command=)
rm -f "$PLIST"
rm -rf "$APP"

echo "Uninstalled $LABEL"
