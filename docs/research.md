# State of the art

Research date: 2026-10-01.

## Hardware and platform facts

- CORSAIR advertises the XENEON EDGE as a 2560x720 five-point touchscreen.
- The attached panel is visible to CoreGraphics at 2560x720 and 60 Hz.
- The touch controller identifies as WingCoolTouch/WCH `27c0:0859`.
- macOS has no first-party iCUE support for this product.
- HID userspace plus CoreGraphics event injection avoids kernel extensions,
  SIP changes, and DriverKit deployment friction.

## Existing implementations

| Project | Relevant result |
| --- | --- |
| `Shadowhusky/xeneon-toolbox` | Native Swift service with Device Mode switch, `0x0d` decoding, gestures, fallback, and recovery |
| `Myseri/xeneon-edge-multitouch-macos` | Most detailed USB/DriverKit investigation; observed firmware acknowledging the Windows switch but withholding multitouch |
| `ymlaine/TouchscreenDriver` | Mature userspace absolute single-touch mapping |
| `ajvwhite/MacXeneonEdgeTouchDriver` | Userspace single-touch service |
| `kemalandic/edgecontrol` | Dashboard/kiosk application with touch support |

## Decision

Do not build another dashboard and do not begin with DriverKit. Extract the
dependency-free Swift compatibility core from `xeneon-toolbox`, retain its
single-touch fallback, and make the hardware behavior observable through a
small CLI.

The apparently conflicting multitouch results may reflect firmware revisions,
host setup, or an unverified upstream claim. Unit tests prove report parsing
and gesture behavior, not that a specific panel emits report `0x0d`. Live HID
diagnostics on each target Mac remain required.

## Menu bar

A driver should not alter global macOS UI. Apps intended to occupy the panel
can hide the menu bar and Dock through standard full-screen/kiosk presentation.
System-wide menu-bar suppression would be intrusive and is outside this
compatibility layer.
