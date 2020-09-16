// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Farm",
    products: [
        .library(
            name: "Farm",
            targets: ["Farm"]),
    ],
    dependencies: [
        .package(name: "Ink", url: "https://github.com/johnsundell/ink.git", from: "0.5.0"),
        .package(name: "Yams", url: "https://github.com/jpsim/Yams.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "Farm",
            dependencies: [
                "Ink",
                "Yams"
            ]),
        .testTarget(
            name: "FarmTests",
            dependencies: ["Farm"]),
    ]
)
