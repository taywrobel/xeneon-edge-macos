#!/bin/bash

set -euo pipefail

LABEL="com.github.xeneon-edge.touch"
APP="${1:-$HOME/Applications/Xeneon Touch.app}"
BIN="$APP/Contents/MacOS/xeneon-touch"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG_DIR="$HOME/Library/Logs/XeneonEdge"
DOMAIN="gui/$(id -u)"

if [[ ! -x "$BIN" ]]; then
  echo "Xeneon Touch executable not found: $BIN" >&2
  exit 1
fi

launchctl bootout "$DOMAIN" "$PLIST" 2>/dev/null || true

while read -r pid command; do
  if [[ "$command" == "$BIN"* ]]; then
    kill "$pid"
  fi
done < <(ps ax -o pid=,command=)

mkdir -p "$HOME/Library/LaunchAgents" "$LOG_DIR"
cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>$BIN</string>
    <string>run</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>ProcessType</key>
  <string>Interactive</string>
  <key>ThrottleInterval</key>
  <integer>2</integer>
  <key>StandardOutPath</key>
  <string>$LOG_DIR/service.log</string>
  <key>StandardErrorPath</key>
  <string>$LOG_DIR/service.log</string>
</dict>
</plist>
EOF

plutil -lint "$PLIST" >/dev/null
launchctl bootstrap "$DOMAIN" "$PLIST"
launchctl kickstart -k "$DOMAIN/$LABEL"

echo "Started Xeneon Touch."
echo "Log: $LOG_DIR/service.log"
