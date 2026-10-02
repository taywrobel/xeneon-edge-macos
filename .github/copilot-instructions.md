# Copilot instructions

This repository is a macOS 14+ Swift 6 compatibility layer for the CORSAIR
XENEON EDGE touchscreen.

- Run `make verify` before completing code changes. Run `make test-full` when
  full Xcode is available.
- Run `make package` for distribution or release changes.
- Keep `XeneonTouchCore` deterministic and independent of IOKit/CoreGraphics.
- Keep platform integration in `XeneonTouchDriver`.
- Preserve the mouse-interface fallback because multitouch report `0x0d` may
  be firmware-dependent.
- Do not require SIP changes, kernel extensions, root access, or private
  entitlements.
- Hardware claims require diagnostics from an attached panel; tests alone are
  not evidence that reports stream.
- Keep the package dependency-free unless a native framework cannot solve the
  requirement.
- Keep `VERSION`, release tags, and `CHANGELOG.md` aligned.
- Read `AGENTS.md` and `docs/research.md` before changing HID behavior.
