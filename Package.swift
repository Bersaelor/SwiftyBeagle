// swift-tools-version:4.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyBeagle",
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/Kitura.git", .upToNextMinor(from: "2.5.0")),
        .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", .upToNextMinor(from: "1.7.2")),
        .package(url: "https://github.com/IBM-Swift/Kitura-CouchDB.git", .upToNextMinor(from: "2.1.0")),
        .package(url: "https://github.com/IBM-Swift/Kitura-StencilTemplateEngine.git", .upToNextMajor(from: "1.10.0"))
        ],
    targets: [
        .target(
            name: "SwiftyBeagle",
            dependencies: ["Kitura" , "HeliumLogger", "CouchDB", "KituraStencil"],
            exclude: ["ExampleiOS"]),
        .testTarget(
            name: "SwiftyBeagleTests",
            dependencies: ["SwiftyBeagle"])
        ]
)
