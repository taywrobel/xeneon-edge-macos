# Support

## Before filing an issue

1. Confirm **Xeneon Touch** is enabled under both **Input Monitoring** and
   **Accessibility** in System Settings.
2. Quit other XENEON or generic touchscreen drivers; only one process can seize
   the device.
3. Confirm the XENEON is connected for both video and USB touch.
4. Check the service:

   ```bash
   make status
   tail -50 ~/Library/Logs/XeneonEdge/service.log
   ```

5. Run hardware diagnostics from a source checkout:

   ```bash
   swift run xeneon-touch list-displays
   swift run xeneon-touch display-modes
   swift run xeneon-touch diagnose
   ```

## Permission changes after updates

Development and ad-hoc builds can cause macOS to request privacy permissions
again. Re-enable the final installed **Xeneon Touch** app, not a terminal or an
older copy.

## What to include

- Mac model and Apple Silicon/Intel architecture
- macOS version
- Xeneon Touch version
- Video and USB connection topology
- Whether single touch, dragging, scrolling, or multitouch works
- Sanitized diagnostic output without serial numbers
