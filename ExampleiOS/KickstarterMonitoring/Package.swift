// swift-tools-version:4.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KickstarterMonitoring",
    dependencies: [
        .package(url: "../../", .upToNextMinor(from: "0.1.5")),
        ],
    targets: [
        .target(
            name: "KickstarterMonitoring",
            dependencies: ["SwiftyBeagle"],
            path: "",
            sources: ["Sources",
                      "Sources/KickstarterMonitoring/Model"
//                      "../SwiftyBeagleExample/Model",
//                      "../SwiftyBeagleExample/Feed.swift"
            ]),
        .testTarget(
            name: "KickstarterMonitoringTests",
            dependencies: ["KickstarterMonitoring"]),
        ]
)
