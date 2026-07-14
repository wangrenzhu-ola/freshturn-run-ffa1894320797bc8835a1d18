// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FreshTurn",
    platforms: [
        .macOS(.v12),
        .iOS(.v14)
    ],
    products: [
        .library(name: "FreshTurnCore", targets: ["FreshTurnCore"])
    ],
    targets: [
        .target(name: "FreshTurnCore"),
        .testTarget(name: "FreshTurnCoreTests", dependencies: ["FreshTurnCore"])
    ],
    swiftLanguageVersions: [.v5]
)

