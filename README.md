# XENEON Edge for macOS

A native compatibility layer for the CORSAIR XENEON EDGE touchscreen. It maps
the panel's absolute HID coordinates to the correct macOS display, injects
direct touch interactions, and exposes diagnostics for the connected hardware.

> Community project. Not affiliated with or endorsed by CORSAIR.

## Install

### Latest GitHub release

Run the checksum-verifying installer:

```bash
curl -fsSL https://raw.githubusercontent.com/taywrobel/xenon-edge-macos/master/scripts/install-release.sh \
  | bash
```

Or download `Xeneon-Touch-<version>.zip` from
[Releases](https://github.com/taywrobel/xenon-edge-macos/releases), extract it,
and double-click `Install.command`.

The installer places `Xeneon Touch.app` in `~/Applications`, configures a
per-user login service, and opens the relevant Privacy & Security pane. Enable
**Xeneon Touch** under:

1. **Input Monitoring**
2. **Accessibility**

No root access, kernel extension, DriverKit extension, or disabled SIP is
required. Release artifacts are ad-hoc signed unless a release maintainer
provides a Developer ID identity; macOS may therefore require right-clicking
`Install.command` and choosing **Open** on first launch.

To uninstall, run the included `Uninstall.command`.

The connected panel is detected as a 2560x720 external display. Its touch
controller is a WingCoolTouch/WCH HID device (`27c0:0859`) with:

- a 10-contact digitizer report (`0x0d`);
- a mouse-compatible absolute-position fallback (`0x07`);
- raw ranges of X `0...16383` and Y `0...9599`.

## Current status

| Capability | Status |
| --- | --- |
| Native 2560x720 display | Works without this project |
| Touch mapped to the XENEON EDGE | Implemented |
| Tap, drag, and one-finger scroll | Implemented |
| Two-finger scroll and pinch | Implemented when report `0x0d` streams |
| Mouse-interface fallback | Implemented |
| Reconnect, sleep/wake, and display-layout recovery | Implemented |
| Preserve focus and pointer on the working display | Implemented |
| Hide the menu bar on the XENEON only | Not supported by macOS per display |

Earlier research found the multitouch interface silent on macOS even after the
Windows HID mode switch was replayed. A newer implementation reports success
by setting Digitizer Device Mode (`0x0d/0x52`) through `IOHIDDeviceSetValue`.
Firmware revisions may behave differently, so this project keeps the fallback
path and treats live report diagnostics as the source of truth.

## Requirements

- macOS 14 or newer
- XENEON EDGE connected for display and USB touch
- Input Monitoring permission to read HID reports
- Accessibility permission to inject pointer events

Building from source additionally requires the Swift 6 toolchain. Full Xcode
is needed only for the complete XCTest suite; Command Line Tools can build the
app and run smoke tests.

## Build from source

```bash
make verify
swift build -c release
make test-full # complete XCTest suite; requires full Xcode
make install
```

Run hardware diagnostics:

```bash
swift run xeneon-touch list-displays
swift run xeneon-touch display-modes
swift run xeneon-touch diagnose
```

Run the compatibility service:

```bash
swift run -c release xeneon-touch run
```

`make status` inspects the login service. `make uninstall` removes it.

The installer creates `~/Applications/Xeneon Touch.app`, signs it with a stable
bundle identifier, and starts it through launchd. macOS attaches Input
Monitoring and Accessibility grants to that app identity. The app remains
running while either permission is pending and activates automatically after
both are granted.

Grant the resulting executable Input Monitoring and Accessibility access in
**System Settings > Privacy & Security**. Only one process should seize the
touch controller at a time.

Successful startup prints:

```text
Xeneon touch interface seized — native trackpad routing disabled.
Xeneon Edge connected — touch active.
```

If the seizure warning appears instead, quit other touchscreen utilities and
restart the service. Without exclusive ownership, macOS also treats the panel
as a trackpad and can route touches to whichever display was previously active.

When a touch begins while the pointer is on another display, the driver returns
the pointer and restores the previously frontmost app after the gesture.

macOS does not provide a supported way for a background compatibility service
to hide the menu bar and reclaim its reserved area on only one display.
Application presentation options affect every display, while native fullscreen
dedicates the XENEON to a single app. Enable macOS menu-bar auto-hide to reclaim
the area globally, or use fullscreen mode in an app intended to occupy the
XENEON. The driver does not place an overlay over the menu bar.

## Architecture

- `XeneonTouchCore`: hardware-independent report parsing, coordinate mapping,
  filters, and gesture state machines.
- `XeneonTouchDriver`: IOKit HID discovery/capture, display identification,
  mode switching, and CoreGraphics event injection.
- `xeneon-touch`: headless service and hardware diagnostics.

See [docs/architecture.md](docs/architecture.md) and
[docs/research.md](docs/research.md) before changing the HID protocol.

## Packaging and releases

Create the exact distributable produced by CI:

```bash
make package
```

This writes a versioned ZIP and `SHA256SUMS` to `dist/`. `VERSION` is the
release source of truth. Pushing a matching tag such as `v1.0.0` runs the
release workflow and publishes both files.

Set `CODESIGN_IDENTITY` to a Developer ID Application identity when producing
a signed release locally. Without it, packaging uses an ad-hoc signature.

See [CONTRIBUTING.md](CONTRIBUTING.md), [SUPPORT.md](SUPPORT.md), and
[SECURITY.md](SECURITY.md).

## Provenance

The initial compatibility core was extracted from
[`Shadowhusky/xeneon-toolbox`](https://github.com/Shadowhusky/xeneon-toolbox)
at commit `8358d26`, with its dashboard and network dependencies removed.
That project is MIT licensed; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
