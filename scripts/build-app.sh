#!/bin/bash

set -euo pipefail

LABEL="com.github.xeneon-edge.touch"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(cat "$ROOT/VERSION")"
OUTPUT="${1:-$ROOT/dist/Xeneon Touch.app}"
IDENTITY="${CODESIGN_IDENTITY:--}"
CONTENTS="$OUTPUT/Contents"
BIN="$CONTENTS/MacOS/xeneon-touch"

case "$OUTPUT" in
  *.app) ;;
  *)
    echo "Output path must end in .app: $OUTPUT" >&2
    exit 2
    ;;
esac

cd "$ROOT"
swift build -c release --product xeneon-touch

rm -rf "$OUTPUT"
mkdir -p "$CONTENTS/MacOS"
install -m 755 ".build/release/xeneon-touch" "$BIN"

cat > "$CONTENTS/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>xeneon-touch</string>
  <key>CFBundleIdentifier</key>
  <string>$LABEL</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>Xeneon Touch</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>$VERSION</string>
  <key>CFBundleVersion</key>
  <string>$VERSION</string>
  <key>LSMinimumSystemVersion</key>
  <string>14.0</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSInputMonitoringUsageDescription</key>
  <string>Xeneon Touch reads touchscreen HID reports to map touches to the XENEON EDGE display.</string>
</dict>
</plist>
EOF

plutil -lint "$CONTENTS/Info.plist" >/dev/null
if [[ "$IDENTITY" == "-" ]]; then
  codesign --force --deep --sign - --identifier "$LABEL" "$OUTPUT"
else
  codesign --force --deep --options runtime --timestamp --sign "$IDENTITY" "$OUTPUT"
fi
codesign --verify --deep --strict "$OUTPUT"

echo "$OUTPUT"
