// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StaticContent",
    products: [
        .library(
            name: "StaticContent",
            targets: ["StaticContent"]),
    ],
    dependencies: [
        .package(name: "Ink", url: "https://github.com/johnsundell/ink.git", from: "0.5.0"),
        .package(name: "Yams", url: "https://github.com/jpsim/Yams.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "StaticContent",
            dependencies: [
                "Ink",
                "Yams"
            ]),
        .testTarget(
            name: "StaticContentTests",
            dependencies: ["StaticContent"]),
    ]
)
