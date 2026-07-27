// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppFormValidation",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(name: "AppFormValidation", targets: ["AppFormValidation"])
    ],
    targets: [
        .target(name: "AppFormValidation"),
        .testTarget(name: "AppFormValidationTests", dependencies: ["AppFormValidation"])
    ]
)
