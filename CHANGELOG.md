# Changelog

All notable changes are documented here. This project follows
[Semantic Versioning](https://semver.org/).

## [Unreleased]

- Removed the XENEON menu-bar cover because an overlay cannot reclaim macOS's
  reserved menu-bar area and could remain as a black strip after wake.

## [0.1.0] - 2026-10-01

- Added absolute touch mapping for the CORSAIR XENEON EDGE on macOS.
- Added exclusive seizure of all three composite HID interfaces.
- Added single-touch fallback, dragging, scrolling, and multitouch report parsing.
- Added pointer and frontmost-application restoration after XENEON gestures.
- Added an XENEON-only, non-activating menu-bar cover.
- Added reconnect, sleep/wake, display-layout, and native-mode handling.
- Added diagnostics, smoke tests, XCTest coverage, app packaging, and login startup.

[Unreleased]: https://github.com/taywrobel/xenon-edge-macos/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/taywrobel/xenon-edge-macos/releases/tag/v0.1.0
