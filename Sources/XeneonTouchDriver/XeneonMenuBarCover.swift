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
  private var observers: [NSObjectProtocol] = []
  private var refreshTimer: Timer?
  private var freshInsetTimer: Timer?
  private var freshInset: CGFloat?
  private var lastLoggedState: String?

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

    observers.append(
      NotificationCenter.default.addObserver(
        forName: NSApplication.didChangeScreenParametersNotification,
        object: nil,
        queue: .main
      ) { [weak self] _ in
        MainActor.assumeIsolated { self?.screenGeometryChanged() }
      })
    let workspaceNotifications = NSWorkspace.shared.notificationCenter
    for name in [NSWorkspace.didWakeNotification, NSWorkspace.screensDidWakeNotification] {
      observers.append(
        workspaceNotifications.addObserver(
          forName: name,
          object: nil,
          queue: .main
        ) { [weak self] _ in
          MainActor.assumeIsolated { self?.screenGeometryChanged() }
        })
    }
    refreshTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
      MainActor.assumeIsolated { self?.refresh() }
    }
    freshInsetTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) {
      [weak self] _ in
      MainActor.assumeIsolated { self?.refreshFromFreshProcess() }
    }
    screenGeometryChanged()
  }

  public func stop() {
    panel?.orderOut(nil)
    refreshTimer?.invalidate()
    refreshTimer = nil
    freshInsetTimer?.invalidate()
    freshInsetTimer = nil
    for observer in observers {
      NotificationCenter.default.removeObserver(observer)
      NSWorkspace.shared.notificationCenter.removeObserver(observer)
    }
    observers.removeAll()
    panel = nil
  }

  public func refresh() {
    guard let panel else { return }
    guard let edge = EdgeDisplayLocator.current(), let screen = Self.screen(for: edge.id) else {
      panel.orderOut(nil)
      return
    }

    let height = freshInset ?? Self.topInset(for: screen)
    guard height > 1 else {
      panel.orderOut(nil)
      logState(displayID: edge.id, screen: screen, height: height, visible: false)
      return
    }
    let frame = NSRect(
      x: screen.frame.minX,
      y: screen.frame.maxY - height,
      width: screen.frame.width,
      height: height
    )
    if panel.frame != frame { panel.setFrame(frame, display: true) }
    panel.orderFrontRegardless()
    logState(displayID: edge.id, screen: screen, height: height, visible: true)
  }

  public static func currentTopInset(for displayID: CGDirectDisplayID) -> CGFloat? {
    guard let screen = screen(for: displayID) else { return nil }
    return topInset(for: screen)
  }

  private func screenGeometryChanged() {
    freshInset = nil
    panel?.orderOut(nil)
    refreshFromFreshProcess(after: 0.5)
    refreshFromFreshProcess(after: 2)
  }

  private func refreshFromFreshProcess(after delay: TimeInterval = 0) {
    guard delay > 0 else {
      refreshFromFreshProcess()
      return
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
      self?.refreshFromFreshProcess()
    }
  }

  private func refreshFromFreshProcess() {
    guard let edge = EdgeDisplayLocator.current() else {
      freshInset = nil
      panel?.orderOut(nil)
      return
    }
    guard let inset = Self.probeTopInset(for: edge.id) else {
      refresh()
      return
    }
    freshInset = inset
    refresh()
  }

  private static func probeTopInset(for displayID: CGDirectDisplayID) -> CGFloat? {
    guard let executableURL = Bundle.main.executableURL else { return nil }

    let output = Pipe()
    let process = Process()
    process.executableURL = executableURL
    process.arguments = ["screen-inset", "--display", String(displayID)]
    process.standardOutput = output
    process.standardError = FileHandle.nullDevice

    do {
      try process.run()
      process.waitUntilExit()
    } catch {
      return nil
    }
    guard process.terminationStatus == 0 else { return nil }
    let data = output.fileHandleForReading.readDataToEndOfFile()
    guard
      let value = String(data: data, encoding: .utf8)?
        .trimmingCharacters(in: .whitespacesAndNewlines),
      let inset = Double(value)
    else { return nil }
    return CGFloat(inset)
  }

  private static func topInset(for screen: NSScreen) -> CGFloat {
    max(0, screen.frame.maxY - screen.visibleFrame.maxY)
  }

  private func logState(
    displayID: CGDirectDisplayID, screen: NSScreen, height: CGFloat, visible: Bool
  ) {
    let state = "\(displayID):\(screen.frame):\(screen.visibleFrame):\(height):\(visible)"
    guard state != lastLoggedState else { return }
    lastLoggedState = state
    print(
      "XENEON menu cover: display=\(displayID) frame=\(screen.frame) "
        + "visibleFrame=\(screen.visibleFrame) inset=\(height) "
        + (visible ? "shown" : "hidden"))
  }

  private static func screen(for displayID: CGDirectDisplayID) -> NSScreen? {
    NSScreen.screens.first {
      guard
        let number = $0.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber
      else { return false }
      return number.uint32Value == displayID
    }
  }
}
