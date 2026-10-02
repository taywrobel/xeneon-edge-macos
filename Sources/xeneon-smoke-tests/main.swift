import Foundation
import XeneonTouchCore

private final class TestResults: @unchecked Sendable {
  var failures = 0
}

private let results = TestResults()

private func check(_ condition: @autoclosure () -> Bool, _ message: String) {
  if condition() {
    print("PASS: \(message)")
  } else {
    results.failures += 1
    FileHandle.standardError.write(Data("FAIL: \(message)\n".utf8))
  }
}

private func checkReportDecoding() {
  var payload = [UInt8](repeating: 0, count: 53)
  payload[0] = 0x21
  payload[1] = 0x34
  payload[2] = 0x12
  payload[3] = 0x78
  payload[4] = 0x56
  payload[52] = 1

  check(
    DigitizerReport.parse(payload: payload)
      == [RawContact(id: 2, x: 0x1234, y: 0x5678)],
    "decodes a 0x0d contact record"
  )
  check(
    DigitizerReport.parse(payload: Array(payload.prefix(3))).isEmpty,
    "rejects a truncated contact record"
  )
}

private func checkCoordinateMapping() {
  let calibration = AxisCalibration(minX: 0, maxX: 16_383, minY: 0, maxY: 9_599)
  let display = DisplayRect(x: 100, y: 200, width: 2_560, height: 720)
  let point = CoordinateMapper.mapToScreen(
    rawX: 16_383,
    rawY: 9_599,
    calibration: calibration,
    display: display
  )
  check(point == ScreenPoint(x: 2_660, y: 920), "maps HID maxima to the display corner")
  check(display.contains(ScreenPoint(x: 100, y: 200)), "display contains its top-left point")
  check(
    !display.contains(ScreenPoint(x: 2_660, y: 920)),
    "display excludes its bottom-right boundary"
  )
}

private func checkSingleTouchFallback() {
  var decoder = HIDTouchDecoder()
  decoder.ingest(page: 0x01, usage: 0x30, value: 1_234)
  decoder.ingest(page: 0x01, usage: 0x31, value: 5_678)
  decoder.ingest(page: 0x09, usage: 0x01, value: 1)
  check(
    decoder.rawX == 1_234 && decoder.rawY == 5_678 && decoder.contact,
    "decodes the mouse-interface fallback"
  )
}

private func checkGestureRecognition() {
  func contact(_ id: Int, _ x: Double, _ y: Double) -> TouchContact {
    TouchContact(id: id, point: ScreenPoint(x: x, y: y))
  }

  var recognizer = MultiTouchRecognizer()
  _ = recognizer.update(contacts: [contact(0, 100, 100), contact(1, 200, 100)])
  check(
    recognizer.update(contacts: [contact(0, 100, 130), contact(1, 200, 130)])
      == [
        .scroll(dx: 0, dy: 0, phase: .began),
        .scroll(dx: 0, dy: 30, phase: .changed),
      ],
    "recognizes a two-finger pan"
  )

  var tap = TouchStateMachine()
  let point = ScreenPoint(x: 50, y: 60)
  _ = tap.update(contact: true, point: point)
  check(
    tap.update(contact: false, point: nil) == [.press(point), .release(point)],
    "turns a single contact into a tap"
  )
}

private func checkDisplayModeChoice() {
  let modes = [
    DisplayModeCandidate(number: 10, width: 1_920, height: 1_080, density: 1, flags: 0),
    DisplayModeCandidate(number: 28, width: 2_560, height: 720, density: 1, flags: 0),
  ]
  check(EdgeModeChooser.best(from: modes)?.number == 28, "selects the native 2560x720 mode")
}

checkReportDecoding()
checkCoordinateMapping()
checkSingleTouchFallback()
checkGestureRecognition()
checkDisplayModeChoice()

if results.failures > 0 {
  FileHandle.standardError.write(Data("\(results.failures) smoke test(s) failed\n".utf8))
  exit(1)
}

print("All compatibility smoke tests passed.")
