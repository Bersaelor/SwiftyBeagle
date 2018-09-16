// swift-tools-version:4.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KickstarterMonitoring",
    dependencies: [
        .package(url: "https://github.com/Bersaelor/SwiftyBeagle", .upToNextMinor(from: "0.1.5")),
        ],
    targets: [
        .target(
            name: "KickstarterMonitoring",
            dependencies: ["SwiftyBeagle"]),
        .testTarget(
            name: "KickstarterMonitoringTests",
            dependencies: ["KickstarterMonitoring"]),
        ]
)
