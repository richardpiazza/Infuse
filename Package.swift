// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Infuse",
    platforms: [
        .macOS(.v13),
        .macCatalyst(.v16),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Infuse",
            targets: ["Infuse"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swhitty/swift-mutex.git", from: "0.0.6"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Infuse",
            dependencies: [
                .product(name: "Mutex", package: "swift-mutex"),
            ],
        ),
        .testTarget(
            name: "InfuseTests",
            dependencies: ["Infuse"]),
    ],
    swiftLanguageModes: [
        .v6,
    ],
)

for target in package.targets {
    var settings = target.swiftSettings ?? []
    settings.append(contentsOf: [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    ])
    target.swiftSettings = settings
}
