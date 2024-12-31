// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "swift-codeowners",
    products: [
        .library(name: "CodeOwners", targets: ["CodeOwners"]),
    ],
    targets: [
        .target(name: "CodeOwners"),
        .testTarget(
            name: "CodeOwnersTests",
            dependencies: ["CodeOwners"]
        ),
    ]
)
