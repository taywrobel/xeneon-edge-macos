# Architecture

## Data flow

1. `IOHIDManager` matches WingCoolTouch/WCH `27c0:0859`.
2. Each HID interface is inspected for axes and digitizer usages.
3. The driver requests multi-input mode through Digitizer Device Mode
   (`usage page 0x0d`, usage `0x52`, value `2`).
4. Report `0x0d` is decoded as ten five-byte contact slots. If it never
   streams, generic-desktop X/Y and Button 1 values provide single-touch input.
5. Coordinates are normalized from device ranges and mapped into the live
   CoreGraphics bounds of the XENEON EDGE.
6. Gesture state machines emit pointer, scroll, and zoom actions.
7. CoreGraphics posts tagged events and restores the cursor after touch ends.
8. If the gesture began while another display owned the pointer, the previously
   frontmost application is reactivated after the touch or momentum completes.
9. A non-activating AppKit panel covers the XENEON menu-bar strip only.

## Target responsibilities

### XeneonTouchCore

Pure value types and state machines. It has no HID or display discovery and is
covered by unit tests.

### XeneonTouchDriver

Owns device matching, report callbacks, permissions, panel identity, display
mode access, event injection, reconnect handling, and diagnostics.

### xeneon-touch

Provides a headless service plus commands for hardware inventory and display
mode diagnosis. It is intentionally separate from any dashboard or kiosk UI.

## Safety invariants

- Device removal releases held buttons and active scroll gestures.
- A failed exclusive open degrades explicitly to non-exclusive operation.
- Every interface of the composite touch controller is seized directly,
  including the mouse-emulation interface, so macOS cannot route duplicate
  trackpad events to the previously active display.
- Synthetic pointer and scroll events enter at the HID event tap after the
  global pointer is placed on the touched XENEON coordinate.
- The fallback remains available until a valid `0x0d` report arrives.
- Display bounds are refreshed because arrangement and scaling can change
  without USB re-enumeration.
- Synthetic events are tagged so they are not mistaken for physical mouse
  movement.
- The menu-bar cover cannot become key or main, so touching it does not take
  workspace focus.
