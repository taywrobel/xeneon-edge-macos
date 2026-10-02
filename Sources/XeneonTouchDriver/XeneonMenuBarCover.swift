import AppKit
import CoreGraphics

/// Covers and intercepts the menu bar on the XENEON EDGE only.
@MainActor
public final class XeneonMenuBarCover {
  private final class CoverPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
  }

  private var panel: CoverPanel?
  private var observer: NSObjectProtocol?
  private var refreshTimer: Timer?

  public init() {}

  public func start() {
    guard panel == nil else {
      refresh()
      return
    }

    let panel = CoverPanel(
      contentRect: .zero,
      styleMask: [.borderless, .nonactivatingPanel],
      backing: .buffered,
      defer: false
    )
    panel.backgroundColor = .black
    panel.isOpaque = true
    panel.hasShadow = false
    panel.hidesOnDeactivate = false
    panel.isReleasedWhenClosed = false
    panel.level = NSWindow.Level(rawValue: NSWindow.Level.statusBar.rawValue + 1)
    panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
    panel.animationBehavior = .none
    self.panel = panel

    observer = NotificationCenter.default.addObserver(
      forName: NSApplication.didChangeScreenParametersNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      MainActor.assumeIsolated { self?.refresh() }
    }
    refreshTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
      MainActor.assumeIsolated { self?.refresh() }
    }
    refresh()
  }

  public func stop() {
    panel?.orderOut(nil)
    refreshTimer?.invalidate()
    refreshTimer = nil
    if let observer {
      NotificationCenter.default.removeObserver(observer)
      self.observer = nil
    }
    panel = nil
  }

  public func refresh() {
    guard let panel else { return }
    guard let edge = EdgeDisplayLocator.current(), let screen = screen(for: edge.id) else {
      panel.orderOut(nil)
      return
    }

    let height = max(24, NSStatusBar.system.thickness)
    let frame = NSRect(
      x: screen.frame.minX,
      y: screen.frame.maxY - height,
      width: screen.frame.width,
      height: height
    )
    if panel.frame != frame { panel.setFrame(frame, display: true) }
    panel.orderFrontRegardless()
  }

  private func screen(for displayID: CGDirectDisplayID) -> NSScreen? {
    NSScreen.screens.first {
      guard
        let number = $0.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber
      else { return false }
      return number.uint32Value == displayID
    }
  }
}
