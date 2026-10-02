// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "xeneon-edge-macos",
  platforms: [.macOS(.v14)],
  products: [
    .library(name: "XeneonTouchCore", targets: ["XeneonTouchCore"]),
    .library(name: "XeneonTouchDriver", targets: ["XeneonTouchDriver"]),
    .executable(name: "xeneon-touch", targets: ["xeneon-touch"]),
    .executable(name: "xeneon-smoke-tests", targets: ["xeneon-smoke-tests"]),
  ],
  targets: [
    .target(name: "XeneonTouchCore"),
    .target(
      name: "XeneonTouchDriver",
      dependencies: ["XeneonTouchCore"]
    ),
    .executableTarget(
      name: "xeneon-touch",
      dependencies: ["XeneonTouchCore", "XeneonTouchDriver"]
    ),
    .executableTarget(
      name: "xeneon-smoke-tests",
      dependencies: ["XeneonTouchCore"]
    ),
    .testTarget(
      name: "XeneonTouchCoreTests",
      dependencies: ["XeneonTouchCore"]
    ),
  ]
)
