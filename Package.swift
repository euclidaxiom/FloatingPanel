// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "FloatingPanel",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "FloatingPanel",
            targets: ["FloatingPanel"]),
    ],
    dependencies: [
        .package(url: "https://github.com/soffes/HotKey.git", from: "0.2.1"),
        .package(url: "https://github.com/euclidaxiom/VisualEffectView.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "FloatingPanel",
            dependencies: [
                "HotKey",
                "VisualEffectView",
            ]),
    ]
)
