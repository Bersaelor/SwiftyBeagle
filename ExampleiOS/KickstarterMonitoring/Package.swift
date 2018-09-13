// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KickstarterMonitoring",
    dependencies: [
        .package(url: "../../", .upToNextMinor(from: "0.1.4")),
        ],
    targets: [
        .target(
            name: "KickstarterMonitoring",
            dependencies: ["SwiftyBeagle"],
            path: "",
            sources: ["Sources",
                      "../SwiftyBeagleExample/Model",
                      "../SwiftyBeagleExample/Feed.swift"]),
        .testTarget(
            name: "KickstarterMonitoringTests",
            dependencies: ["KickstarterMonitoring"]),
        ]
)
