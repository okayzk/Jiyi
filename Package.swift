// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Jiyi",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Jiyi", targets: ["Jiyi"])
    ],
    dependencies: [
        // The app's one dependency: it installs updates. Keep this version equal to
        // SPARKLE_VERSION in Scripts/sparkle.sh, whose tools sign the appcast;
        // Scripts/build.sh refuses a mismatch.
        .package(url: "https://github.com/sparkle-project/Sparkle", exact: "2.10.1")
    ],
    targets: [
        .executableTarget(
            name: "Jiyi",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle")
            ],
            path: "Sources/Jiyi"
        )
    ]
)
