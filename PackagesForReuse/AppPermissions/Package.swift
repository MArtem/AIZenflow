// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppPermissions",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(name: "AppPermissions", targets: ["AppPermissions"])
    ],
    targets: [
        .target(name: "AppPermissions"),
        .testTarget(name: "AppPermissionsTests", dependencies: ["AppPermissions"])
    ]
)
