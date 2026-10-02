#!/bin/bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(cat "$ROOT/VERSION")"
REQUESTED="${1:-v$VERSION}"
REQUESTED="${REQUESTED#v}"
DIST="$ROOT/dist"
NAME="Xeneon-Touch-$VERSION"
STAGE="$DIST/$NAME"
ARCHIVE="$DIST/$NAME.zip"

if [[ "$REQUESTED" != "$VERSION" ]]; then
  echo "Tag/version mismatch: requested $REQUESTED, VERSION contains $VERSION" >&2
  exit 2
fi

rm -rf "$STAGE"
rm -f "$ARCHIVE" "$DIST/SHA256SUMS"
mkdir -p "$STAGE"

"$ROOT/scripts/build-app.sh" "$STAGE/Xeneon Touch.app"
install -m 755 "$ROOT/packaging/Install.command" "$STAGE/Install.command"
install -m 755 "$ROOT/packaging/Uninstall.command" "$STAGE/Uninstall.command"
install -m 755 "$ROOT/scripts/register-service.sh" "$STAGE/register-service.sh"
install -m 644 "$ROOT/packaging/README.txt" "$STAGE/README.txt"
install -m 644 "$ROOT/LICENSE" "$STAGE/LICENSE"
install -m 644 "$ROOT/THIRD_PARTY_NOTICES.md" "$STAGE/THIRD_PARTY_NOTICES.md"

ditto -c -k --norsrc --keepParent "$STAGE" "$ARCHIVE"
(
  cd "$DIST"
  shasum -a 256 "$(basename "$ARCHIVE")" > SHA256SUMS
)

echo "$ARCHIVE"
echo "$DIST/SHA256SUMS"
