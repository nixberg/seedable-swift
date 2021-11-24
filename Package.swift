// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "seedable-swift",
    products: [
        .library(
            name: "Seedable",
            targets: ["Seedable"]),
    ],
    targets: [
        .target(
            name: "Seedable"),
        .testTarget(
            name: "SeedableTests",
            dependencies: ["Seedable"]),
    ]
)
