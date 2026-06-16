// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppStateMachine",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(name: "AppStateMachine", targets: ["AppStateMachine"])
    ],
    targets: [
        .target(name: "AppStateMachine"),
        .testTarget(name: "AppStateMachineTests", dependencies: ["AppStateMachine"])
    ]
)
