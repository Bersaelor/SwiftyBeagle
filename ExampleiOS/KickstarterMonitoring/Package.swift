// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KickstarterMonitoring",
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/Kitura.git", .upToNextMinor(from: "1.0.0")),
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
