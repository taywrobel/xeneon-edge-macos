# Contributing

## Development loop

```bash
make verify
swift build -c release
make test-full # when full Xcode is installed
make package
```

Keep HID parsing and gesture decisions in `XeneonTouchCore` so they remain
unit-testable without hardware. Keep IOKit, CoreGraphics, permissions, and
display discovery in `XeneonTouchDriver`.

Hardware-dependent changes must record:

1. macOS version and Mac architecture;
2. XENEON EDGE firmware or hardware revision when available;
3. report ID, byte length, and relevant diagnostic output;
4. behavior after replug and sleep/wake.

Do not weaken the single-touch fallback when changing the `0x0d` path. Do not
require SIP changes, kernel extensions, private entitlements, or root access.

## Releases

1. Update `VERSION` and `CHANGELOG.md`.
2. Run `make verify`, `make test-full`, and `make package`.
3. Inspect the ZIP and verify `shasum -a 256 -c dist/SHA256SUMS`.
4. Commit the version change and push a matching `v<version>` tag.

The release workflow rejects a tag that does not match `VERSION`.
