// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "Confetti3D",
    platforms: [
            .iOS(.v15)
        ],
    products: [
        .library(
            name: "Confetti3D",
            targets: ["Confetti3D"]),
    ],
    targets: [
        .target(
            name: "Confetti3D",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "Confetti3DTests",
            dependencies: ["Confetti3D"]
        ),
    ]
)
