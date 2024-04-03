// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let name = "SharedDependencies"   
let asyncAlgorithms: Target.Dependency = .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
let strictConcurrency: SwiftSetting = .enableExperimentalFeature("StrictConcurrency")

let package = Package(
    name: name,
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .visionOS(.v1),
        .tvOS(.v15),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: name,
            targets: [name]
        )
    ],
    dependencies: [
//        .package(url: "git@github.com:apple/swift-async-algorithms", from: "1.0.0")//,
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0")
    ],
    targets: [
        .target(
            name: name,
            dependencies: [
                asyncAlgorithms
            ],
            swiftSettings: [
                strictConcurrency
            ]
        ),
        .testTarget(
            name: "DependenciesTests",
            dependencies: [
                "SharedDependencies"
            ],
            swiftSettings: [
                strictConcurrency
            ]
        ),
    ]
)
