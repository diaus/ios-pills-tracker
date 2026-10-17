// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Data",
    // `.macOS` lets the tests run on the Mac with `swift test`; the app ships on iOS only.
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "Data", targets: ["Data"]),
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(url: "https://github.com/hmlongco/Factory.git", from: "2.5.0"),
    ],
    targets: [
        .target(
            name: "Data",
            dependencies: [
                "Domain",
                .product(name: "FactoryKit", package: "Factory"),
            ],
            swiftSettings: [.enableUpcomingFeature("StrictConcurrency")]
        ),
        .testTarget(
            name: "DataTests",
            dependencies: ["Data"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
