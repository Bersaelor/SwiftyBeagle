// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KickstarterMonitoring",
    dependencies: [
        .package(url: "../../", .upToNextMinor(from: "0.0.1")),
    ],
    targets: [
        .target(
            name: "KickstarterMonitoring",
            dependencies: []),
        .testTarget(
            name: "KickstarterMonitoringTests",
            dependencies: ["KickstarterMonitoring"]),
    ]
)
