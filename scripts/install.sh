#!/bin/bash

set -euo pipefail

LABEL="com.github.xeneon-edge.touch"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$HOME/Applications/Xeneon Touch.app"

cd "$ROOT"
"$ROOT/scripts/build-app.sh" "$APP"
"$ROOT/scripts/register-service.sh" "$APP"

echo "Installed and started $LABEL"
echo "App: $APP"
echo
echo "Grant Xeneon Touch both permissions when macOS requests them:"
echo "  Input Monitoring"
echo "  Accessibility"
echo "System Settings > Privacy & Security"

open "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent"
