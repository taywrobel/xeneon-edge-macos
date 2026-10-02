# Agent guide

This is a macOS 14+ Swift 6 package for the CORSAIR XENEON EDGE touch
compatibility layer.

## Commands

- Build: `swift build`
- Release build: `swift build -c release`
- Portable smoke tests: `make test`
- Full XCTest suite: `make test-full` (requires full Xcode)
- Lint: `swift format lint --recursive --strict Sources Tests Package.swift`
- Local verification: `make verify`
- Hardware inventory: `swift run xeneon-touch list-displays`
- HID diagnostics: `swift run xeneon-touch diagnose`
- Install per-user service: `make install`
- Inspect service: `make status`
- Remove service: `make uninstall`
- Build release artifact: `make package`

## Boundaries

- `XeneonTouchCore` must remain deterministic and hardware-independent.
- `XeneonTouchDriver` owns IOKit/CoreGraphics integration and permissions.
- Preserve the mouse-interface fallback; report `0x0d` may remain silent on
  some firmware.
- Never require disabling SIP or installing a kernel extension.
- Do not claim hardware behavior from unit tests. Confirm it with diagnostics
  on an attached panel and document the environment.
- Treat display identification by EDID vendor/model as authoritative; geometry
  is only a fallback because users can change resolution and arrangement.
- Keep the package dependency-free unless a platform API cannot meet the need.
- Keep `VERSION`, release tags, and changelog entries aligned.

Read `docs/research.md` before changing the mode switch or report decoder.
