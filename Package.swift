// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyBeagle",
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/Kitura.git", .upToNextMinor(from: "2.5.0")),
        .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", .upToNextMinor(from: "1.7.2")),
        .package(url: "https://github.com/IBM-Swift/Kitura-CouchDB.git", .upToNextMinor(from: "2.1.0")),
        .package(url: "https://github.com/IBM-Swift/SwiftyRequest.git", .upToNextMajor(from: "2.0.1")),
    ],
    targets: [
        .target(
            name: "SwiftyBeagle",
            dependencies: ["Kitura" , "HeliumLogger", "CouchDB", "SwiftyRequest"]),
        .testTarget(
            name: "SwiftyBeagleTests",
            dependencies: ["SwiftyBeagle"]),
    ]
)
