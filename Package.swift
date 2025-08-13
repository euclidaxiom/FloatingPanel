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
            targets: ["FloatingPanel"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/euclidaxiom/VisualEffectView.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "FloatingPanel",
            dependencies: [
                "VisualEffectView"
            ]),
        .executableTarget(
            name: "FloatingPanelDemo",
            dependencies: ["FloatingPanel"],
        ),
    ]
)
