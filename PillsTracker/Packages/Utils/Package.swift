// swift-tools-version: 6.0
import PackageDescription

/// Project-independent helpers over the standard library and Apple's system frameworks, meant to be
/// reused in other projects: no dependency on Domain, Data or any third-party package.
let package = Package(
    name: "Utils",
    // `.macOS` lets the tests run on the Mac with `swift test`; the app ships on iOS only.
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "Utils", targets: ["Utils"]),
    ],
    targets: [
        .target(
            name: "Utils",
            swiftSettings: [.enableUpcomingFeature("StrictConcurrency")]
        ),
        .testTarget(
            name: "UtilsTests",
            dependencies: ["Utils"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
